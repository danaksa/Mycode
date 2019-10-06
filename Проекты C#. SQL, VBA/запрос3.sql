(select distinct '' as head, '' as sampleorderno, '' as VERT, '' as PERES, CAST(SAMPLEDATE as DATE) as SAMPLEDATE, lab, productdescription, SAMPLEPLACE, 
''''||MAX(PHENOLSN) as PHENOLSN, ''''||MAX(H2SSN) as H2SSN, ''''||MAX(PHORMALDHEGYDSN) as PHORMALDHEGYDSN, ''''||MAX(AMMONIYSN) as AMMONIYSN, ''''||MAX(NO2SN) as NO2SN, ''''||MAX(NOSN) as NOSN, ''''||MAX(SO2SN) as SO2SN, ''''||MAX(COSN) as COSN, ''''||MAX(DUSTSN) as DUSTSN
from
(
select distinct '' as head, st.sampleorderno as sampleorderno, SR.BATCHNO as BATCHNO, st.sampledate as sampledate,
st.lab as lab, st.productdescription as productdescription,
sr.SHORTNAME as SHORTNAME, sr.reslimsorderno as reslimsorderno, ST.SAMPLEPLACE as SAMPLEPLACE, SR.METHODNAME
from ipm_samplest st, ipm_sampleresults sr
where
SR.SHORTNAME in('����������', '����������������', '���������������������', '�����������', '�����������������', 'NO', '����������������', 'CO', '�����������������') 
and sr.batchno = st.batchno
and testtype = '���������'
) a
pivot
(
max(BATCHNO) for SHORTNAME in (
'����������' as PHENOLSN,
'����������������' as H2SSN,
'���������������������' as PHORMALDHEGYDSN,
'�����������' as AMMONIYSN, '�����������������' as NO2SN, 'NO' as NOSN, '����������������' as SO2SN, 'CO' as COSN, '�����������������' as DUSTSN )
) group by lab, productdescription, SAMPLEPLACE, SAMPLEDATE order by SAMPLEDATE)