<?php

/**
 *
 * Main module
 * Import prices agent
 *
 * @author
 * @since   22/01/2012
 *
 * @link
 */




use Product\SuppliersProductFilterForBranch;
use Product\SuppliersProductRepository;

use Bitrix\Main\Application;
use Bitrix\Main\DB\Connection;
use Exception;

IncludeModuleLangFile(__FILE__);

class JpMotorAutoImportAgent
{
    static $run_string = 'JpMotorAutoImportAgent::run();';

    private const TABLE_MATCHING = 'jp_matching';
    /**
    * выводить ли лог?
    * используется для проверки агента из админки
    */
    static $output_debug = false;

    /**
     * Хранимый лог
     */
    static $output_log = '';
    
    
    /**
     * статистика по поставщикам
     */
    static $suppliers_stat = array();
    
    
    /**
     * Объект базы данных
     */
    protected $database;

    /*
     * Файл лога
     */
    static $log_file = "/upload/jpmotor/pricelists/import.log";

    /*
     * Макс. размер файла лога
     */
    const MAX_LOG_SIZE = 1000000;

    /**
     * Основная функция дебага
     */
    public static function run($test = false)
    {
        /*
    	* Можем ли мы запустить ещё один крон?
    	*/
        if(!JpMotorAutoModule::canRunAnotherCron())
        	return self::$run_string;


        @set_time_limit(0);

        // disable all buffering
        while(ob_get_level())
        	ob_end_flush();
        flush();


        /*
        * Отключим отладку
        */
        JpMotorAutoDebug::$enabled = false;

        /*
         * А есть ли крон?
         */
        if (!self::checkCron()) {
            $ar = array(
               "MESSAGE" => GetMessage('LM_AUTO_MAIN_NEED_CRON'),
               "TAG" => "LM_NEED_CRON",
               "MODULE_ID" => "jpmotor",//было linemedia
               "ENABLE_CLOSE" => "N"
            );
            $ID = CAdminNotify::Add($ar);

            /*
             * Запрещено выполнять импорт не из под крона
             */
            if(!$test) return self::$run_string;

        } else {
            CAdminNotify::DeleteByTag("LM_NEED_CRON");
        }


        $agent = new JpMotorAutoImportAgent();
        $files = $agent->getNewFiles();

        if (count($files) > 0) {
        	$agent->prepareImportData();

            /*
             * Парсим файлы
             */
            //foreach ($files as $file) {
            //    $agent->parseFile($file);
            //}
            $agent->parseFile(array_shift(array_values($files)));
            
            
            /*
	         * Cобытие окончания отработки агента
	         * Были ли импортированы файлы и сколько
	         */
	        $events = GetModuleEvents("jpmotor", "OnAfterPriceListAllImport");
	        while ($arEvent = $events->Fetch()) {
	            try {
	                ExecuteModuleEventEx($arEvent, array(count($files), $files, self::$suppliers_stat, self::$output_log));
	            } catch (Exception $e) {
	                throw $e;
	            }
	        }

	        /* Удаление позиций с брендом камаз или присутсвие в названии*/
            $repository = new SuppliersProductRepository();
            $filter = new SuppliersProductFilterForBranch;
            $filter->addBrand('Камаз');
            $repository->removeByFilter($filter);

            $filter = new SuppliersProductFilterForBranch;
            $filter->setSubName('Камаз');
            $repository->removeByFilter($filter);

	        \JpMotor\Product\Agent\SuppliersProductCalculationAgent::cleanResult();
        }

        /*
         * Очистим старые прайсы
         */
        //нужно перенести в другое место
//        $agent->cleanupOldFiles();
//        BXClearCache(true);
//        $obcache = new CPHPCache;
//        $obcache->CleanDir();


        return self::$run_string;
    }


    /**
     * Проверка наличия новых файлов
     */
    public static function getNewFiles()
    {
        $path = $_SERVER['DOCUMENT_ROOT'].'/upload/jpmotor/pricelists/new/';
        $files = array();
        foreach (glob($path . '*.csv') as $filename) {
            $files []= basename($filename);
        }

        /*
         * Нет прайсов
         */
        if (count($files) < 1) {
            return;
        }

        /*
         * Проверяем файл за файлом
         */
        foreach ($files as $i => $file) {
            $filename = $_SERVER['DOCUMENT_ROOT'].'/upload/jpmotor/pricelists/new/' . $file;

            /*
             * Вывод отладочной информации
             */
            self::log(GetMessage('LM_PRICELIST_FOUND', array('#FILE#' => $file)));

            /*
             * Читаем ли файл
             */
            if (!is_readable($filename)) {
                self::log(GetMessage('LM_PRICELIST_NOT_READABLE', array('#FILE#' => $file)));
                self::moveIncorrectFile($file);
                unset($files[$i]);
            }

            /*
             * Загружен ли файл до конца?
             */
            if ($handle = fopen($filename, 'r')) {
                // http://php.net/manual/en/function.flock.php
                if (!flock($handle, LOCK_EX)) {
                    unset($files[$i]);
                } else {
                    flock($handle, LOCK_UN);
                }
                fclose($handle);
            }
        }

        return $files;
    }



    /**
     * Соберём информацию полезную для импорта
     */
    public function prepareImportData()
    {
        
        $this->database = Application::getConnection();


        /*
         * Кодировка для импорта всегда UTF, потому что кодировка таблицы продуктов прописана насильно
         */
        $this->database->query("SET NAMES 'utf8'");
    }


    /**
     * Разбор файла.
     */
    public function parseFile($file)
    {
        if(!file_exists($_SERVER['DOCUMENT_ROOT'] . '/upload/jpmotor/pricelists/new/')) {
            self::log('Error! Create /upload/jpmotor/pricelists/new/ folder!');
            return false;
        }

        $filename = $_SERVER['DOCUMENT_ROOT'].'/upload/jpmotor/pricelists/new/' . $file;

        /*
         * Вывод отладочной информации
         */
        self::log(GetMessage('LM_PRICELIST_START', array('#FILE#' => $file)));

        /*
        * Переименуем файл, чтобы его не видели другие кроны
        */
        rename($filename, $filename . '.progress');
        $filename .= '.progress';
        $file .= '.progress';

        $filename_parts = explode('_', $file);


        //$supplier_id = (string) $filename_parts[0]; - поставщик может содержать в идентификаторе символ '_'
        array_pop($filename_parts);
        $task_id = (string) array_pop($filename_parts);
        $supplier_id = join('_', $filename_parts);
        $suppliers_standart = array('jpmotorOmskVlg	','jpmotorOmsk','jpmotorMoskva');
        if(!$supplier_id) {
            $supplier_id = $task_id;
            $task_id = 0;
        }

        /*
         * Получим объект поставщика
         */

        $supplier = new JpMotorAutoSupplier($supplier_id);

        if (!$supplier->exists()) {
            self::log(GetMessage('LM_PRICELIST_SUPPLIER_NOT_FOUND', array('#SUPPLIER#' => $supplier_id)), false, LM_AUTO_DEBUG_ERROR);
            $this->moveIncorrectFile($file);
            return;
        }


        /*
         * Cобытие начала загрузки прайса
         */
        $events = GetModuleEvents("jpmotor", "OnBeforePriceListImport");
        while ($arEvent = $events->Fetch()) {
            try {
                ExecuteModuleEventEx($arEvent, array(&$filename, &$supplier_id));
            } catch (Exception $e) {
                throw $e;
            }
        }

        /*
         * Открываем файл
         */
        try {
            $handle = fopen($filename, "r");

            // Попытаемся заблокировать файл.
            if (!flock($handle, LOCK_EX)) {
                fclose($handle);
                return;
            }
        } catch (Exception $e) {
            self::log(GetMessage('LM_PRICELIST_OPEN_ERROR', array('#ERROR#' => $e->GetMessage())));
            return;
        }
        if(!in_array($supplier_id,$suppliers_standart)){
        $this->zeroSupplierNotPrice($supplier_id);
        }
		/*
		 * Обнулим товары поставщика
		 */
		$this->zeroSupplierProducts($supplier_id);


		/*
		 * Проверим кодировку файла.
		 * Она должна быть UTF-8.
		 */
        $cmd = 'file -bi ' . escapeshellarg($filename);
        $cmd_result = system($cmd, $cmd_result);
        $response = explode(';', $cmd_result);
        $charset  = explode('=', $response[1]);
        $encoding = trim($charset[1]);
        if ($encoding != 'utf-8') {
            $from = 'cp1251'; // потому что file -bi приравнивает cp1251 к iso-8859-1. но у нас-то или 1251 или юникод
            $cmd = 'iconv -f ' . $from . ' -t utf8 "' . $filename . '" -o "' . $filename . '.tmp"';
            self::log('iconv from ' . $from. ' to utf-8');
            system($cmd, $cmd_result);
            unlink($filename);
            rename($filename . '.tmp', $filename);
        }

        /*
         * Установка локали.
         */
        @setlocale(LC_COLLATE, "ru_RU.UTF-8");
        @setlocale(LC_CTYPE, "ru_RU.UTF-8");


        /*
         * Получаем пользовательские поля.
         */
        $lmfields = new JpMotorCustomFields();

        $custom_fields = $lmfields->getFields();


        /*
         * Построчно импортируем данные
         */
        $count = 0;
        $errors = 0;
        $total_price = 0;
        self::log('Start import');
        $time_per_iteration = microtime(1);
        $cnt = 0;
        while (($data = fgets($handle)) !== FALSE) {

            $cnt++;
            // remove escapes
            $data = str_getcsv(stripcslashes($data), ";");
            //remove BOM charsets
            $data[0] = trim(preg_replace('/\x{feff}/u', '', $data[0]));

            /*
             * Событие перед добавленим в базу новой записи
             */
            $events = GetModuleEvents("jpmotor", "OnBeforeDbItemAdd");
            while ($arEvent = $events->Fetch()) {
                try {
                    ExecuteModuleEventEx($arEvent, array(&$data));
                } catch (Exception $e) {
                    throw $e;
                }
            }

            /*
             * Определение полей в CSV
             *
             * Старые прайсы:
             * AN113K;AKEBONO;"Название детали AN-113K";1052;10;-1
             *
             * Новые прайсы
             * AN113K;AKEBONO;"Название детали AN-113K";1052;10;-1;300;custom1;custom2;custom3
             */
            $brand_title    = trim($data[0]);
            $article        = trim($data[1]);
            $title          = trim($data[2]);
            $price          = trim($data[3]);
            // clean price
            $price = preg_replace("/[^0-9,.]/", "", $price);
            $quantity       = trim($data[4]);
            // clean quantity
            $quantity = preg_replace("/[\,\.]0*$/", "", $quantity);
			//alexv: уберем текст перед числом
			$quantity = preg_replace("/^[^0-9]*/", "", $quantity);
            $group_id       = trim($data[5]);
            $weight         = trim($data[6]);

            /*
             * Почистим поле price от пробелов и заменим , на . (иначе пропадет дробная часть при вызове метода ForSQL)
             */
            $price = str_replace(',', '.', $price);
            $price = str_replace(' ', '', $price);

            /*
             * Количество фиксированных полей.
             */
            $index = 7;

            $original_article = $article;
            $article = JpMotorAutoPartsHelper::clearArticle($article);
            if(!in_array($supplier_id,$suppliers_standart)){
                $brand_title = JpMotorAutoPartsHelper::clearBrand($brand_title);
                $title = self::gettitle($brand_title, $article, $title, $supplier_id, $original_article, $price, $quantity, $group_id, $weight);
            }

            //не импортируем не соотвествующие стандартным прайсам позиции
//            if($title === ""){
//                self::log('Not import'.$title);
//                continue;
//            }
            /*
             * Не импортируем товар с количеством 0 или менее
             */
            /*if (floatval($quantity) <= 0) {
                $errors++;
                self::log('Null quantity [' . $cnt . ']: ' . "'" . join("', '", $data) . "'");
                continue;
            }*/

            /*
             * Вставим значение в БД
             */
            $sql_title              = $this->database->getSqlHelper()->ForSQL($title);
            $sql_article            = $this->database->getSqlHelper()->ForSQL($article);
            $sql_original_article   = $this->database->getSqlHelper()->ForSQL($original_article);
            $sql_brand_title        = $this->database->getSqlHelper()->ForSQL($brand_title);
            $sql_price              = $this->database->getSqlHelper()->ForSQL($price);
            $sql_quantity           = $this->database->getSqlHelper()->ForSQL($quantity);
            $sql_group_id           = $this->database->getSqlHelper()->ForSQL($group_id);
            $sql_weight             = $this->database->getSqlHelper()->ForSQL($weight);

            /*
             * Заменим запятую в цене.
             */
            $sql_price = number_format(str_replace(',', '.', $sql_price), 2, '.', '');

            /*
             * Вставим кастомные значения в БД.
             */
            $sql_custom_fields = '';
            $sql_custom_values = '';
            if (!empty($custom_fields)) {
                $custom_fields_vars = array();
                $custom_values_vars = array();
                foreach ($custom_fields as $custom_field) {
                    $custom_fields_vars []= "`".$custom_field['code']."`";
                    $custom_values_vars []= "'".$this->database->getSqlHelper()->ForSQL(trim($data[$index]))."'";
                    $index++;
                }
                $sql_custom_fields = ', '.implode(', ', $custom_fields_vars);
                $sql_custom_values = ', '.implode(', ', $custom_values_vars);
            }

            $sql = "
                INSERT INTO `b_jp_products` (
                    `title`,
                    `article`,
                    `original_article`,
                    `brand_title`,
                    `price`,
                    `quantity`,
                    `group_id`,
                    `weight`,
                    `supplier_id`
                     $sql_custom_fields
                ) VALUES (
                    '$sql_title',
                    '$sql_article',
                    '$sql_original_article',
                    '$sql_brand_title',
                    '$sql_price',
                    '$sql_quantity',
                    '$sql_group_id',
                    '$sql_weight',
                    '$supplier_id'
                     $sql_custom_values
                );
            ";

            $rs = $this->database->Query($sql);
            if(!$rs) {
                $debug = true;
            }
            $count++;
            $total_price += floatval($sql_price);

            if($count % 50000 == 0) {
            	$spent = microtime(1) - $time_per_iteration;
            	$time_per_iteration = microtime(1);
            	self::log($count . ' entries imported [50000 per ' . number_format($spent, 2) . 's]');
            }

        }
        fclose($handle);

        self::log('Total ' . $count . ' entries imported');

        self::log(GetMessage('LM_PRICELIST_FINISHED', array('#FILE#' => $file)));

        /*
         * Переместим файл в успешно добавленные
         */
        $this->moveCorrectFile($file);

        // запишем в статистику
        self::$suppliers_stat[] = array(
            'supplier_id' => $supplier_id,
            'count' => $count,
            'error' => $errors,
        );

        /*
         * событие окончания загрузки прайса
         */
        $events = GetModuleEvents("jpmotor", "OnAfterPriceListImport");
        while ($arEvent = $events->Fetch()) {
            try {
            //	self::log('Event start:' . print_r($arEvent, 1));
                ExecuteModuleEventEx($arEvent, array($supplier_id, $count, $task_id, $total_price));
            } catch (Exception $e) {
                throw $e;
            }
        }

        // а есть ли ещё файлы для парсинга?
        // мы парсили только первый
        $files = $this->getNewFiles();
        if (count($files) > 0)
			$this->parseFile(array_shift(array_values($files)));
    }

    //Очистка title - получение из таблицы jp_matching
    public function gettitle($brand_title, $article, $title, $supplier_id, $original_article, $price, $quantity, $group_id, $weight){
        try {
            $sql = 'SELECT distinct title FROM `' . self::TABLE_MATCHING . '` WHERE `brand_title` = "' . $brand_title . '" and `article` = "' . $article . '"';
            if (empty($this->database)) {
                $this->database = Application::getConnection();
            }
            $result = $this->database->Query($sql);
            if ($result->getSelectedRowsCount() < 1) {
                $sql_title              = $this->database->getSqlHelper()->ForSQL($title);
                $sql_article            = $this->database->getSqlHelper()->ForSQL($article);
                $sql_original_article   = $this->database->getSqlHelper()->ForSQL($original_article);
                $sql_brand_title        = $this->database->getSqlHelper()->ForSQL($brand_title);
                $sql_price              = $this->database->getSqlHelper()->ForSQL($price);
                $sql_quantity           = $this->database->getSqlHelper()->ForSQL($quantity);
                $sql_group_id           = $this->database->getSqlHelper()->ForSQL($group_id);
                $sql_weight             = $this->database->getSqlHelper()->ForSQL($weight);
                $sql = "
                INSERT INTO `jp_notprice` (
                    `title`,
                    `article`,
                    `original_article`,
                    `brand_title`,
                    `price`,
                    `quantity`,
                    `group_id`,
                    `weight`,
                    `supplier_id`
                ) VALUES (
                    '$sql_title',
                    '$sql_article',
                    '$sql_original_article',
                    '$sql_brand_title',
                    '$sql_price',
                    '$sql_quantity',
                    '$sql_group_id',
                    '$sql_weight',
                    '$supplier_id'
                );
            ";
                $rs = $this->database->Query($sql);
                preg_match('/\((.+)\)/', $title, $m);
                if(!empty($m[0])){
                    $m = ' '.$m[0].' ';
                }else{
                    $m = '';
                }
                return mb_eregi_replace('[^а-яё ]', '', $title).$m.$brand_title;
                //"/([^а-яё ])(\(.*\))/"
            } else {
                while ($data = $result->fetch()) {
                    $titlematch = $data['title'];
                }
                return $titlematch;
            }
        }catch(Exeption $e){
            self::log('Error when matching title'.$e);
        }
    }
    /**
     * Переместить ошибочный файл в соответствующую папку
     */
    public static function moveIncorrectFile($file)
    {
        $old_filename = $_SERVER['DOCUMENT_ROOT'].'/upload/jpmotor/pricelists/new/' . $file;
        $new_filename = $_SERVER['DOCUMENT_ROOT'].'/upload/jpmotor/pricelists/error/' . $file;
        try {
            rename($old_filename, $new_filename);
            self::log(GetMessage('LM_PRICELIST_INCORRECT_MOVED', array('#FILE#' => $file)));
        } catch (Exception $e) {
            self::log(GetMessage('LM_PRICELIST_INCORRECT_MOVED_ERROR', array('#FILE#' => $file)));
        }
    }


    /**
     * Переместить успешно добавленный файл в бекап
     */
    public static function moveCorrectFile($file)
    {
        unlink($_SERVER['DOCUMENT_ROOT'].'/upload/jpmotor/pricelists/new/' . $file);
    }


    /**
     * Обнулить количество товаров у поставщика
     */
    public function zeroSupplierProducts($supplier_id)
    {
        $supplier_id = (string) $supplier_id;

        try {
            // Подключение к БД
            if (empty($this->database)) {
                $this->database = Application::getConnection();
            }
            $this->database->Query("DELETE FROM `b_jp_products` WHERE `supplier_id` = '" . $this->database->getSqlHelper()->ForSQL($supplier_id) . "'");
        } catch (Exception $e) {
            throw $e;
            return false;
        }

        /*
         * Вывод отладочной информации
         */
        self::log(GetMessage('LM_PRICELIST_SUPPLIER_PRODUCTS_REMOVED', array('#SUPPLIER#' => $supplier_id)));
    }

    /**
     * Обнулить количество товаров не соответствующих стандартным прайсам
     */
    public function zeroSupplierNotPrice($supplier_id)
    {
        $supplier_id = (string) $supplier_id;

        try {
            // Подключение к БД
            if (empty($this->database)) {
                $this->database = Application::getConnection();
            }
            $this->database->Query("DELETE FROM `jp_notprice` WHERE `supplier_id` = '" . $this->database->getSqlHelper()->ForSQL($supplier_id) . "'");
        } catch (Exception $e) {
            throw $e;
            return false;
        }

        /*
         * Вывод отладочной информации
         */
        self::log('Удалена информация из таблицы jp_notprice по поставщику '.$supplier_id);
    }



    /**
     * Удалить старые прайсы.
     */
    public function cleanupOldFiles()
    {
        $lifetime_days = COption::GetOptionInt('linemedia.auto', 'LM_AUTO_MAIN_OLD_PRICELISTS_LIFETIME_DAYS', 14);
        $lifetime = $lifetime_days * 86400;

        /*
        * Удалим успешно загруженные прайслисты
        */
        $root = $_SERVER['DOCUMENT_ROOT'] . '/upload/jpmotor/pricelists/success/';
        $success_folders = scandir($root);
        foreach ($success_folders as $folder) {
           if (!in_array($folder, array(".", "..")) && is_dir($root . $folder)) {
                try {
                    $this->cleanupDir($root . $folder . '/', $lifetime);
                } catch (Exception $e) {

                }
            }
        }

        /*
         * Не импортированные прайсы тоже удалим, потому что они ...
         */
        $root = $_SERVER['DOCUMENT_ROOT'] . '/upload/jpmotor/pricelists/error/';
        try {
            $this->cleanupDir($root, $lifetime, false);
        } catch (Exception $e) {

        }


        /*
         * Исходные файлы прайсов удаляются через N дней
         */
        $root = $_SERVER['DOCUMENT_ROOT'] . '/upload/jpmotor/pricelists/sources/';
        $success_folders = scandir($root);
        foreach ($success_folders as $folder) {
           if (!in_array($folder, array(".", "..")) && is_dir($root . $folder)) {
                try {
                    $this->cleanupDir($root . $folder . '/', $lifetime);
                } catch (Exception $e) {

                }
            }
        }

		/*
         * Удалим логи
         */
		$root = $_SERVER['DOCUMENT_ROOT'] . '/upload/jpmotor/logs/';

		foreach (glob($root . '*') as $filename) {
			if (time() - filemtime($filename) > $lifetime && is_file($filename)) {
				try {
				unlink($filename);
				} catch (Exception $e) {

				}
			}
		}

    }


    /**
     * Чистка одной директории
     */
    private function cleanupDir($path, $lifetime, $rm_emty_dirs = true)
    {
        /*
         * Удалить все CSV
         */
        foreach (glob($path . '*') as $filename) {
            if (time() - filemtime($filename) > $lifetime) {
                unlink($filename);
            }
        }


        /*
         * Может можно и папку удалить?
         */
        if ($rm_emty_dirs) {
            $count = 0;
            $files = scandir($path);
            foreach ($files as $file) {
               if (!in_array($file, array(".", ".."))) {
                  $count++;
               }
            }
            if ($count == 0) {
                rmdir($path);
            }
        }
    }



    /**
     * Проверка правильности настроек системы для работы агента из CRON
     */
    public static function checkCron()
    {

        $a = COption::GetOptionString("main", "agents_use_crontab", "Y") == 'N';
        if (!$a) {
            return false;
        }

        $b = COption::GetOptionString("main", "check_agents", "Y") == 'N';
        if (!$b) {
            return false;
        }

        // BX_CRONTAB == true в cron_events.php, поэтому нет смысла в этой проврке, когда запуск из крона (cli)
        if (defined('BX_CRONTAB') && BX_CRONTAB == true && php_sapi_name() != 'cli') {
            return false;
        }

        if (!defined("CHK_EVENT") || CHK_EVENT !== true) {
            if (!defined("BX_CRONTAB_SUPPORT") || BX_CRONTAB_SUPPORT !== true) {
                return false;
            }
        }
        return true;
    }

	/**
	* вывод лога импорта
	*/
    public static function log($str)
    {
        $formatted_message = date('G:i:s') . ' - ' . $str . "\n";

        self::$output_log .= $formatted_message;
        /*
         * На экран
         */
        if(self::$output_debug)
            echo $formatted_message;

        /*
         * В файл.
         */
        $log_file = $_SERVER['DOCUMENT_ROOT']. self::$log_file;

        if (file_exists($log_file) && filesize($log_file) > self::MAX_LOG_SIZE) {
            rename($log_file, str_replace(".log", "_" . date('d.m.Y_G.i') . "_.log", $log_file));
        }

        file_put_contents(
            $_SERVER['DOCUMENT_ROOT']. self::$log_file,
            $formatted_message,
            FILE_APPEND
        );
    }

	/**
	* возвращает целиком собранный лог импорта
	*/
    public static function getLog() {
        return self::$output_log;
    }
}