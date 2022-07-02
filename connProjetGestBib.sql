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

/* Cas d'utilisation "Gestion des emprunts" */
                        
/* ajouter un emprunt */

/* modifier un emprunt */

/* chercher un emprunt */
 
 
/* Cas d'utilisation ""Gestion des adhérents" */

/* ajouter un adhérant */

/* supprimer un adhérant */

/* modifier un adhérant */

/* chercher un adhérant */






























