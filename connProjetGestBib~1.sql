/* creation des tables */

CREATE TABLE catalogue(
codeg number(10) constraint pk_catalogue primary key,
titre varchar2(200) NOT NULL,
NomAut  varchar2(80) NOT NULL,
prenomAut  varchar2(80) NOT NULL,
anEd number (4),
editeur varchar(50) NOT NULL,
domaine varchar(50),
Prix Number(8,3));


create table exemplaire(
codexp VARCHAR(10),
codeg number(10) NOT NULL,
etat char(8) NOT NULL,
disp char(3) NOT NULL,
constraint pk_exemplaire primary key(codexp),
constraint fk_exemplaire_catalogue foreign key(codeg) references catalogue(codeg),
constraint ck_exemplaire_etat check (etat IN ('bon','moyen','mediocre')),
 constraint ck_exemplaire_disp check (disp IN ('oui','non')));
 
create table Adherent(
noAdh number(6) constraint pk_membres primary key,
nom varchar2(80) NOT NULL,
prenom varchar2(80) NOT NULL,
adresse varchar2(200) NOT NULL,
ncin NUMBER (8) UNIQUE,
tel NUMBER(10),
dateAdh DATE NOT NULL,
email VARchar(80) NOT NULL);

CREATE TABLE Emprunt(
codexp varchar(10) NOT NULL,
dateEmp DATE NOT NULL,
noAdh number(6) NOT NULL,
dateRprevue DATE NOT NULL,
datereffective DATE,
constraint fk_emprunts_codexp foreign key (codexp)references exemplaire(codexp),
constraint fk_emprunts_adh foreign key (noAdh) references adherent (noadh), 
constraint pk_emprunts primary key (codexp, dateemp));

/*****ajout ******/
CREATE OR REPLACE TRIGGER AJOUT_EMPRUNT 
BEFORE INSERT ON EMPRUNT 
FOR EACH ROW
declare 
n NUMBER;
m number;
p number;
begin

SELECT count(codexp) into n  from emprunt where (noAdh=:new.noAdh and dateReffective is null)  ;
select count(noAdh) into m from emprunt where :new.codexp=codexp and dateReffective is null;
select count(noAdh) into p from retard where :new.noAdh=noAdh and upper(encours) like 'YES';
if n=5 then RAISE_APPLICATION_ERROR(-20100,'insertion impossible l''adherant a deja 5 empruntS');

else if m>0 then  RAISE_APPLICATION_ERROR(-20100,'exemplaire déja emprunté pas rendu');

else if (:new.dateReffective>sysdate ) then  RAISE_APPLICATION_ERROR(-20100,'La valeur de la date de retour effective ne doit 
pas être antérieure à la date système.');

else if p>0 then  RAISE_APPLICATION_ERROR(-20100,'vous avez une penalite de retard encours');

else if (TO_CHAR(SYSDATE, 'DD')=29 or TO_CHAR(SYSDATE, 'DD')=30) then 
RAISE_APPLICATION_ERROR(-20100,'le jour de retour prévue doit être toujours diffèrent de 29 et de 30');
else 
    INSERT INTO EMPRUNT VALUES(:new.codexp,SYSDATE,:new.noadh,:new.daterprevue,:new.datereffective);
END IF;
END IF;
END IF;
END IF;
END IF;
END;

*****table retard***

CREATE TABLE retard(
                    noadh number(6) NOT NULL,
                    codeg number(10) NOT NULL,
                    dateEmp DATE NOT NULL,
                    datereffective DATE,
                    penalite number NOT NULL,
                    encours char(3) NOT NULL,
                    constraint fk_retard_codeg foreign key (codeg) references catalogue(codeg),
                    constraint fk_retard_adh foreign key (noAdh) references adherent(noadh), 
                    constraint pk_retard primary key(noadh, codeg, dateemp)
                    );
                    
/***********Update emprunt*****************************/
create or replace TRIGGER UPDATE_EMPRUNT 
BEFORE UPDATE ON EMPRUNT
FOR EACH ROW
BEGIN
IF(:NEW.datereffective>:OLD.dateRprevue )THEN
RAISE_APPLICATION_ERROR(-20104,' mise a jour refusé');
ELSE
IF(:NEW.codexp!= :OLD.codexp OR :NEW.dateEmp!= :OLD.dateEmp OR :NEW.noAdh!= :OLD.noAdh OR :NEW.dateRprevue!= :OLD.dateRprevue   ) THEN
RAISE_APPLICATION_ERROR(-20105,' mise a jour refusé');
ELSE UPDATE EMPRUNT set datereffective=:NEW.datereffective;

END IF;
END IF;

END;


/********* supprimer emprint ***********/
CREATE OR REPLACE TRIGGER supp_emp BEFORE 
DELETE ON EMPRUNT 
FOR EACH ROW
BEGIN
        RAISE_APPLICATION_ERROR(-20200,'Suppression impossible.');
END;


/************* chercher emprunt ************/

SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE CHERCHEREMPRUNTCODEG 
( CODECATALOGUE IN NUMBER) AS 
  
  cursor listEmprunt is
  select e.codexp, e.dateEmp,e.noAdh,e.dateRprevue,e.dateReffective from emprunt e , exemplaire ex
  where e.codexp=ex.codexp
  and ex.codeg=codecatalogue;
  vList listEmprunt%ROWTYPE;
  begin
 
  open listEmprunt;
  loop
  fetch listEmprunt into vList ;
  DBMS_OUTPUT.PUT_LINE('Code exemplaire :'||vList.codexp||'Date emprunt  :'|| vList.dateEmp||'Numero adherent  :'|| vList.noAdh||'Date retour prevue :'|| vList.dateRprevue||'Date retour prevue :'|| vList.dateReffective);
  end loop;
  close listEmprunt;
END CHERCHEREMPRUNTCODEG;


CREATE OR REPLACE PROCEDURE CHERCHEREMPRUNTNOADHERENT ( num IN NUMBER) AS  

  cursor listEmprunt is
  select  CODEXP ,DATEEMP ,NOADH ,DATERPREVUE ,DATEREFFECTIVE  from emprunt 
  where noAdh=num;
 
  vList listEmprunt%ROWTYPE;
  begin
 
  open listEmprunt;
  loop
  fetch listEmprunt into vList ;
  DBMS_OUTPUT.PUT_LINE('Code exemplaire :'||vList.codexp||'Date emprunt  :'|| vList.dateEmp||'Numero adherent  :'|| vList.noAdh||'Date retour prevue :'|| vList.dateRprevue||'Date retour prevue :'|| vList.dateReffective);
  end loop;
  close listEmprunt;
END CHERCHEREMPRUNTNOADHERENT;



/************ ajout emprunt *********/
CREATE OR REPLACE TRIGGER AJOUT_EMPRUNT 
BEFORE INSERT ON EMPRUNT 
FOR EACH ROW
declare 
n NUMBER;
m number;
p number;
begin

SELECT count(codexp) into n  from emprunt where (noAdh=:new.noAdh and dateReffective is null)  ;
select count(noAdh) into m from emprunt where :new.codexp=codexp and dateReffective is null;
select count(noAdh) into p from retard where :new.noAdh=noAdh and upper(encours) like 'YES';
if n=5 then RAISE_APPLICATION_ERROR(-20100,'insertion impossible l''adherant a deja 5 empruntS');

else if m>0 then  RAISE_APPLICATION_ERROR(-20100,'exemplaire déja emprunté pas rendu');

else if (:new.dateReffective>sysdate ) then  RAISE_APPLICATION_ERROR(-20100,'La valeur de la date de retour effective ne doit 
pas être antérieure à la date système.');

else if p>0 then  RAISE_APPLICATION_ERROR(-20100,'vous avez une penalite de retard encours');

else if (TO_CHAR(SYSDATE, 'DD')=29 or TO_CHAR(SYSDATE, 'DD')=30) then 
RAISE_APPLICATION_ERROR(-20100,'le jour de retour prévue doit être toujours diffèrent de 29 et de 30');
else 
    INSERT INTO EMPRUNT VALUES(:new.codexp,SYSDATE,:new.noadh,:new.daterprevue,:new.datereffective);
END IF;
END IF;
END IF;
END IF;
END IF;
END;





/************** CHERCHER ADHRENT **********/
create or replace PROCEDURE CHERCHER_ADHERENT_CIN 
( CIN IN NUMBER ) AS 
BEGIN
 SELECT* from ADHERENT where CIN=ncin;
 DBMS_OUTPUT.PUT_LINE('num adherent:'||noAdh||'nom'|| nom||'prenom  :'|| prenom||'adresse:'|| adresse||'cin:'|| ncin||'telephone:'|| tel||'date:'|| dateAdh||'email:'|| email);
 EXCEPTION
WHEN NO_DATA_FOUND THEN
RAISE_APPLICATION_ERROR(-20123,'pas d''adherent avec ce numero cin');
WHEN OTHERS THEN 
RAISE; 
END CHERCHER_ADHERENT_CIN;


/********** CHERCHER EMPRUNT ********/
create or replace PROCEDURE CHERCHEREMPRUNTCODEG 
( CODECATALOGUE IN NUMBER) AS 
  
  cursor listEmprunt is
  select e.codexp, e.dateEmp,e.noAdh,e.dateRprevue,e.dateReffective from emprunt e , exemplaire ex
  where e.codexp=ex.codexp
  and ex.codeg=codecatalogue;
  vList listEmprunt%ROWTYPE;
  begin

  open listEmprunt;
  loop
  fetch listEmprunt into vList ;
  DBMS_OUTPUT.PUT_LINE('Code exemplaire :'||vList.codexp||'Date emprunt  :'|| vList.dateEmp||'Numero adherent  :'|| vList.noAdh||'Date retour prevue :'|| vList.dateRprevue||'Date retour prevue :'|| vList.dateReffective);
  end loop;
  close listEmprunt;
END CHERCHEREMPRUNTCODEG;

create or replace PROCEDURE CHERCHEREMPRUNTNOADHERENT ( num IN NUMBER) AS  

  cursor listEmprunt is
  select  CODEXP ,DATEEMP ,NOADH ,DATERPREVUE ,DATEREFFECTIVE  from emprunt 
  where noAdh=num;

  vList listEmprunt%ROWTYPE;
  begin

  open listEmprunt;
  loop
  fetch listEmprunt into vList ;
  DBMS_OUTPUT.PUT_LINE('Code exemplaire :'||vList.codexp||'Date emprunt  :'|| vList.dateEmp||'Numero adherent  :'|| vList.noAdh||'Date retour prevue :'|| vList.dateRprevue||'Date retour prevue :'|| vList.dateReffective);
  end loop;
  close listEmprunt;
END CHERCHEREMPRUNTNOADHERENT;


/********* AJOUT ADHERENT *******/
create or replace TRIGGER AJOUT_ADHERENT 
BEFORE INSERT ON ADHERENT
FOR EACH ROW 
DECLARE 
nbr number; 
BEGIN
SELECT COUNT (noAdh)into nbr FROM adherent WHERE ncin =:NEW.ncin; 
if (nbr >0) then 
RAISE_APPLICATION_ERROR(-20101,'il est deja adherent'); 
END IF ; 
END;

/********* SUPPRIMER ADHERENT *********/
create or replace TRIGGER SUPP_ADHERENT 
BEFORE DELETE ON ADHERENT 
FOR EACH ROW 
DECLARE 
nbremprunt number;
BEGIN
SELECT COUNT(Codexp) INTO nbremprunt FROM emprunt WHERE noadh =:NEW.noadh;
IF(nbremprunt >0)THEN
RAISE_APPLICATION_ERROR(-20102,'suppression impossible car l''adherent a des emprunts');
END IF ; 
END;

/****** UPDATE  ADHERENT ********/
create or replace TRIGGER UPDATE_ADHERENT 
BEFORE UPDATE ON ADHERENT
FOR EACH ROW
BEGIN
IF(:NEW.ADRESSE!= :OLD.ADRESSE OR :NEW.TEL!= :OLD.TEL OR :NEW.EMAIL!= :OLD.EMAIL) THEN
RAISE_APPLICATION_ERROR(-20105,'mise a jouçr refusé');
END IF;
END;




/*********** CALCUL PENALITE **********/
create or replace PROCEDURE CALCULPENALITE 
(
  DPREVUE IN DATE 
, DEFFECTIVE IN DATE 
) AS 
nbr number;
d1 DATE; 
BEGIN
select r.dateemp into d1 
from retard r
where r.datereffective=DEFFECTIVE ;
nbr:=to_char(DEFFECTIVE,'dd')-to_char(DPREVUE,'dd');
if(nbr>30) then
update retard set penalite=nbr where dateemp=d1;
DBMS_OUTPUT.PUT_LINE('update de penalite faite 1 !!');
else if(nbr<90 and nbr>30) then 
update retard set penalite=nbr*2 where dateemp=d1;
DBMS_OUTPUT.PUT_LINE('update de penalite faite 2 !!');
else 
DBMS_OUTPUT.PUT_LINE('tu dois payer ouvrage !!');
end if;
end if;
END CALCULPENALITE;

