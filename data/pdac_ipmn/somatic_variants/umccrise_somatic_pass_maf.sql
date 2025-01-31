select
    id,
    file_id,
    substring(name, position('SBJ' in name), 8) as subject_id,
    name,
    volume_id,
    volume_name,
    path,
    time_created,
    unique_hash
from data_portal.data_portal_gdsfile
where
    year(time_created) = 2023 and
    regexp_like(name, 'somatic-PASS.maf') and
    substring(name, position('SBJ' in name), 8) in (
'SBJ04156',
'SBJ04157',
'SBJ04158',
'SBJ04159',
'SBJ04160',
'SBJ04161',
'SBJ04162',
'SBJ03819',
'SBJ04163',
'SBJ04164',
'SBJ04165',
'SBJ04166',
'SBJ04167',
'SBJ04168',
'SBJ04169',
'SBJ04170',
'SBJ04171',
'SBJ04172',
'SBJ04173',
'SBJ04174',
'SBJ03811',
'SBJ04175',
'SBJ04176',
'SBJ04177',
'SBJ04178',
'SBJ04179',
'SBJ04180',
'SBJ04181',
'SBJ03805',
'SBJ04182',
'SBJ04183',
'SBJ04184',
'SBJ03841',
'SBJ04185',
'SBJ04186',
'SBJ03840',
'SBJ03898',
'SBJ03899',
'SBJ03900',
'SBJ03901',
'SBJ03902',
'SBJ03903',
'SBJ03904',
'SBJ03905',
'SBJ03906',
'SBJ03907',
'SBJ00519',
'SBJ03908',
'SBJ00521',
'SBJ03909',
'SBJ00515',
'SBJ03910',
'SBJ03911',
'SBJ03912',
'SBJ03913',
'SBJ03914',
'SBJ03915',
'SBJ00523',
'SBJ00525',
'SBJ03916'
) order by name desc;
