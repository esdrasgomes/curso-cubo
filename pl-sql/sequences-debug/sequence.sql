---------------------corrigir sequence


alter sequence seq_tipo_prestador increment by -371;
select seq_tipo_prestador.nextval from dual;
alter sequence seq_tipo_prestador increment by 1;
select seq_tipo_prestador.currval from dual; 

---------------------cria sequence

CREATE SEQUENCE seq_tipo_prestador
    INCREMENT BY 1
    START WITH 1
    MINVALUE 1
    MAXVALUE 9999999
    CYCLE
    CACHE 2;

