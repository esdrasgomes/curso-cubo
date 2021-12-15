----6) Prestador com mais cirurgias em 2017.
SELECT atendime.cd_prestador
, Count(cirurgia_aviso.cd_aviso_cirurgia) nro_cirurgia
FROM atendime
, aviso_cirurgia
, cirurgia_aviso
, cirurgia
WHERE atendime.cd_atendimento = aviso_cirurgia.cd_atendimento
AND aviso_cirurgia.cd_aviso_cirurgia = cirurgia_aviso.cd_aviso_cirurgia
AND cirurgia_aviso.cd_cirurgia = cirurgia.cd_cirurgia       
---AND Trunc(dt_aviso_cirurgia, 'yyyy') = to_date('01/01/2017', 'dd/mm/yyyy')        
AND To_Char(dt_aviso_cirurgia, 'yyyy') = '2017'
GROUP BY atendime.cd_prestador  
ORDER BY 2 DESC 
  
