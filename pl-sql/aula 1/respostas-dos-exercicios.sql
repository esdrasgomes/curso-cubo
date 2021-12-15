-- EXERC�CIO 1
SELECT ATENDIME.CD_ATENDIMENTO
, DT_ATENDIMENTO
,  DT_ALTA
FROM atendime;

-- EXERC�CIO 2
-- OBS: UTILIZEI OUTRA DATA DE ATENDIMENTO
-- USEI A TABELA "CONVENIO" PARA BUSCAR O NOME DO CONVENIO
SELECT ATENDIME.CD_ATENDIMENTO
, PACIENTE.NM_PACIENTE
, CONVENIO.NM_CONVENIO
, ATENDIME.DT_ATENDIMENTO
FROM ATENDIME, CONVENIO, PACIENTE
WHERE ATENDIME.DT_ATENDIMENTO = To_Date('23/08/2002', 'dd/mm/yyyy')

-- EXERC�CIO 3
SELECT PACIENTE.NM_PACIENTE
, CIDADE.CD_CIDADE
, CIDADE.NM_CIDADE
, ATENDIME.CD_ATENDIMENTO
FROM PACIENTE, CIDADE, ATENDIME

---- EXERCÍCIO 4 - Fazer um Select dos pacientes internados durante o mês de agosto de 2014, com idade
----maior ou igual a 50 anoss

SELECT paciente.nm_paciente
, Trunc((SYSDATE - PACIENTE.dt_nascimento)/365) idade 
FROM paciente
, atendime
WHERE atendime.cd_paciente = paciente.cd_paciente
--AND atendime.dt_atendimento BETWEEN To_Date('01/08/2014', 'dd/mm/yyyy') AND To_Date('31/08/2014', 'dd/mm/yyyy')
--AND trunc(atendime.dt_atendimento, 'mm') = To_Date('01/08/2014', 'dd/mm/yyyy')
AND  To_Char(atendime.dt_atendimento, 'mm/yyyy') = '08/2014'
AND ATENDIME.tp_atendimento = 'I'
AND Trunc((SYSDATE - PACIENTE.dt_nascimento)/365) > 50

-- ///////////////////////////////////////////////////////////////////////////

-- PARTE 4 - EXERCICIO 3 - Média do tempo de internação (paciente que tiveram internação, tempo entre
----entrada e alta) por faixa etária (0 a 10, 11 a 18, 19 a 30, 30 a 45, 46 a 60, 60 a 80 e
----maior que 81).

SELECT fx_etaria
, Round(Avg (tempo_de_internacao),2) media_internacao
FROM (
      SELECT  tempo_de_internacao, idade,
      CASE WHEN idade <= 10              THEN '0 a 10'
          WHEN idade BETWEEN 11 AND 18  THEN '11 a 18'         
          WHEN idade BETWEEN 19 AND 30  THEN '19 a 30'         
          WHEN idade BETWEEN 31 AND 45  THEN '31 a 45'         
          WHEN idade BETWEEN 46 AND 60  THEN '46 a 60'         
          WHEN idade BETWEEN 61 AND 80  THEN '61 a 80'         
          WHEN idade > 80               THEN 'Maior que 80'
          ELSE 'fora da fx etaria'         
      END fx_etaria                                             
      FROM(                                                          
            SELECT PACIENTE.nm_paciente                           
            , PACIENTE.dt_nascimento
            , Trunc((SYSDATE - PACIENTE.dt_nascimento)/365) idade
            , round((ATENDIME.dt_alta - ATENDIME.dt_atendimento), 2) tempo_de_internacao
            FROM ATENDIME
            , PACIENTE
            WHERE ATENDIME.CD_PACIENTE = PACIENTE.CD_PACIENTE
            AND ATENDIME.tp_atendimento = 'I'
            AND ATENDIME.dt_alta IS NOT NULL
            AND (ATENDIME.dt_alta - ATENDIME.dt_atendimento) >= 0               
            )
      )                                                      
GROUP BY fx_etaria
ORDER BY 1
--------------------------------------------------------------
------------------------------------------------------------
        SELECT 2.555
        , Round(2.333)  com_round
        ,  Trunc(2.333) com_trunc
         FROM dual