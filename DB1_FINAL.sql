-- Drop tables if they exist
DROP TABLE IF EXISTS Sete;
DROP TABLE IF EXISTS Rad;
DROP TABLE IF EXISTS Flytype;
DROP TABLE IF EXISTS Flyprodusent;
DROP TABLE IF EXISTS Fly;
DROP TABLE IF EXISTS Flyselskap;
DROP TABLE IF EXISTS Flåte;
DROP TABLE IF EXISTS SeteValg;
DROP TABLE IF EXISTS Flyvning;
DROP TABLE IF EXISTS DelFlyvning;
DROP TABLE IF EXISTS DelreiseBillett;
DROP TABLE IF EXISTS Billett;
DROP TABLE IF EXISTS Flyrute;
DROP TABLE IF EXISTS Flyplass;
DROP TABLE IF EXISTS Delreise;
DROP TABLE IF EXISTS Kunde;
DROP TABLE IF EXISTS Billettkjøp;
DROP TABLE IF EXISTS DelFlyvning;
DROP TABLE IF EXISTS DelreiseBillett;
DROP TABLE IF EXISTS Delflyvningsbillett;
DROP TABLE IF EXISTS FlyvningBillett;
DROP TABLE IF EXISTS InnsjekketBagasje;
DROP TABLE IF EXISTS Innsjekking;
DROP TABLE IF EXISTS Fordelsprogram;
DROP TABLE IF EXISTS Mellomlandinger;
DROP TABLE IF EXISTS MedlemAv;
DROP TABLE IF EXISTS RadKonfigurasjon;
DROP TABLE IF EXISTS EkteTid;
DROP TABLE IF EXISTS FlyprodusentNasjonalitet;

-- Opprettelse av Flyprodusent-tabellen
CREATE TABLE Flyprodusent (
    FlyprodusentNavn VARCHAR(50),
    Stiftelsesår INTEGER NOT NULL,
    CONSTRAINT FlyprodusentNavn_pk PRIMARY KEY (FlyprodusentNavn)
);

CREATE TABLE FLyprodusentNasjonalitet(
    Nasjonalitet VARCHAR(50),
    FlyprodusentNavn VARCHAR(50),
    CONSTRAINT FlyprodusentNasjonalitet_pk PRIMARY KEY (Nasjonalitet, FlyprodusentNavn),
    CONSTRAINT FlyprodusentNavn_fk FOREIGN KEY (FlyprodusentNavn) REFERENCES Flyprodusent(FlyprodusentNavn)
);

-- Opprettelse av Flytype-tabellen
CREATE TABLE Flytype (
    FlytypeNavn VARCHAR(50),
    FørsteProduksjonsår INTEGER NOT NULL,
    SisteProduksjonsår INTEGER,
    CONSTRAINT FlytypeNavn_pk PRIMARY KEY (FlytypeNavn),
    CHECK (SisteProduksjonsår IS NULL OR SisteProduksjonsår >= FørsteProduksjonsår)
);

-- Opprettelse av RadKonfigurasjon-tabellen
CREATE TABLE RadKonfigurasjon (
    RadID INTEGER NOT NULL,
    FlyTypeNavn VARCHAR(50) NOT NULL,
    CONSTRAINT RadKonfigurasjon_pk PRIMARY KEY (RadID, FlyTypeNavn),
    CONSTRAINT RadID_fk FOREIGN KEY (RadID) REFERENCES Rad(RadID),
    CONSTRAINT FlyTypeNavn_fk FOREIGN KEY (FlyTypeNavn) REFERENCES FlyType(FlyTypeNavn)
);

-- Opprettelse av Rad-tabellen
CREATE TABLE Rad (
    RadID VARCHAR(50),
    RadNr INTEGER,
    ErNødutgang CHAR(1) NOT NULL CHECK (ErNødutgang IN ('Y', 'N')),
    CONSTRAINT RadID_pk PRIMARY KEY (RadID)
);

-- Opprettelse av Sete-tabellen
CREATE TABLE Sete (
    SeteID INTEGER,
    SetePosisjon VARCHAR(1) NOT NULL,
    RadNr INTEGER NOT NULL,
    CONSTRAINT SeteID_pk PRIMARY KEY (SeteID),
    CONSTRAINT Sete_fk FOREIGN KEY (RadNr) REFERENCES Rad(RadNr)
);

-- Opprettelse av SeteValg-tabellen
CREATE TABLE SeteValg (
    SeteID INTEGER,
    DelFlyvningID INTEGER,
    BillettID INTEGER NOT NULL,
    CONSTRAINT SeteValg_pk PRIMARY KEY (SeteID, DelFlyvningID),
    CONSTRAINT SeteValg_fk FOREIGN KEY (SeteID) REFERENCES Sete(SeteID),
    CONSTRAINT DelFlyvning_fk FOREIGN KEY (DelFlyvningID) REFERENCES DelFlyvning(DelFlyvningID),
    CONSTRAINT Billett_fk FOREIGN KEY (BillettID) REFERENCES DelreiseBillett(BillettID)
);

-- Opprettelse av Fly-tabellen
CREATE TABLE Fly (
    Registreringsnummer VARCHAR(50),
    FlyNavn VARCHAR(50) NOT NULL,
    ÅrSattIDrift INTEGER NOT NULL,
    FlytypeNavn VARCHAR(50) NOT NULL,
    FlyprodusentNavn VARCHAR(50) NOT NULL,
    Serienummer VARCHAR(50) NOT NULL,
    Flyselskapskode VARCHAR(50) NOT NULL,
    UNIQUE (FlyprodusentNavn, Serienummer),
    CONSTRAINT Registreringsnummer_pk PRIMARY KEY (Registreringsnummer),
    CONSTRAINT FlytypeNavn_fk FOREIGN KEY (FlytypeNavn) REFERENCES Flytype(FlytypeNavn),
    CONSTRAINT FlyprodusentNavn_fk FOREIGN KEY (FlyprodusentNavn) REFERENCES Flyprodusent(FlyprodusentNavn),
    CONSTRAINT Flyselskapskode_fk FOREIGN KEY (Flyselskapskode) REFERENCES Flyselskap(Flyselskapskode)
);

-- Opprettelse av Flyselskap-tabellen
CREATE TABLE Flyselskap (
    Flyselskapskode VARCHAR(50),
    FlyselskapsNavn VARCHAR(50) NOT NULL,
    Stiftelsesår INTEGER NOT NULL,
    Nasjonalitet VARCHAR(50) NOT NULL,
    CONSTRAINT Flyselskapskode_pk PRIMARY KEY (Flyselskapskode)
);

-- Opprettelse av Flåte-tabellen
CREATE TABLE Flåte (
    Flåtenavn VARCHAR(50) NOT NULL,
    FlytypeNavn VARCHAR(50),
    Flyselskapskode VARCHAR(50),
    Registreringsnummer VARCHAR(50) NOT NULL,
    CONSTRAINT Flåte_pk PRIMARY KEY (FlytypeNavn, Flyselskapskode),
    CONSTRAINT Registreringsnummer_fk FOREIGN KEY (Registreringsnummer) REFERENCES Fly(Registreringsnummer),
    CONSTRAINT FlytypeNavn_fk FOREIGN KEY (FlytypeNavn) REFERENCES Flytype(FlytypeNavn),
    CONSTRAINT Flyselskapskode_fk FOREIGN KEY (Flyselskapskode) REFERENCES Flyselskap(Flyselskapskode)
);

-- Opprettelse av Flyrute-tabellen
CREATE TABLE Flyrute (
    Flyrutenummer VARCHAR(50),
    UkedagsKode VARCHAR(50) NOT NULL,
    OppstartsDato DATE NOT NULL,
    SluttDato DATE NOT NULL,
    FlytypeNavn VARCHAR(50) NOT NULL,
    Flyselskapskode VARCHAR(50) NOT NULL,
    Startflyplass VARCHAR(50) NOT NULL,
    Endeflyplass VARCHAR(50) NOT NULL,
    PlanlagtAnkomsttid TIME NOT NULL,
    PlanlagtAvgangstid TIME NOT NULL,
    Økonomipris INTEGER NOT NULL,
    PremiumPris INTEGER NOT NULL,
    BudsjettPris INTEGER NOT NULL,
    CONSTRAINT Flyrutenummer_pk PRIMARY KEY (Flyrutenummer),
    CONSTRAINT FlytypeNavn_fk FOREIGN KEY (FlytypeNavn) REFERENCES Flytype(FlytypeNavn),
    CONSTRAINT Flyselskapskode_fk FOREIGN KEY (Flyselskapskode) REFERENCES Flyselskap(Flyselskapskode),
    CONSTRAINT Startflyplass_fk FOREIGN KEY (Startflyplass) REFERENCES Flyplass(Flyplasskode),
    CONSTRAINT Endeflyplass_fk FOREIGN KEY (Endeflyplass) REFERENCES Flyplass(Flyplasskode)
);

-- Opprettelse av Flyplass-tabellen
CREATE TABLE Flyplass (
    Flyplasskode VARCHAR(50),
    Flyplassnavn VARCHAR(100) NOT NULL,
    CONSTRAINT Flyplasskode_pk PRIMARY KEY (Flyplasskode)
);

-- Opprettelse av Flyvning-tabellen
CREATE TABLE Flyvning (
    Løpenummer INTEGER,
    Flyrutenummer VARCHAR(50),
    FlyvningStatus VARCHAR(50),
    Dato DATE NOT NULL,
    PlanlagtAvgangstid TIME NOT NULL,
    PlanlagtAnkomststid TIME NOT NULL,
    Registreringsnummer VARCHAR(50) NOT NULL,
    CHECK (FlyvningStatus IN ('Planned', 'Cancelled', 'Completed', 'Active')),
    CONSTRAINT Flyvning_pk PRIMARY KEY (Løpenummer, Flyrutenummer),
    UNIQUE (Flyrutenummer, Dato),
    CONSTRAINT Flyrutenummer_fk FOREIGN KEY (Flyrutenummer) REFERENCES Flyrute(Flyrutenummer),
    CONSTRAINT Registreringsnummer_fk FOREIGN KEY (Registreringsnummer) REFERENCES Fly(Registreringsnummer)
);

-- Opprettelse av DelFlyvning-tabellen
CREATE TABLE DelFlyvning (
    DelflyvningsID INTEGER,
    Delreisenummer INTEGER NOT NULL,
    Løpenummer INTEGER NOT NULL,
    Flyrutenummer VARCHAR(50) NOT NULL,
    DelFlyvningStatus VARCHAR(50) NOT NULL,
    PlanlagtAnkomsttid TIME NOT NULL,
    PlanlagtAvgangstid TIME NOT NULL,
    CONSTRAINT DelFlyvningsID_pk PRIMARY KEY (DelflyvningsID),
    CONSTRAINT Delreisenummer_fk FOREIGN KEY (Delreisenummer) REFERENCES DelReise(Delreisenummer),
    CONSTRAINT Flyvning_fk FOREIGN KEY (Løpenummer, Flyrutenummer) REFERENCES Flyvning(Løpenummer, Flyrutenummer)
);

-- Opprettelse av DelReise-tabellen
CREATE TABLE DelReise (
    Delreisenummer INTEGER,
    PlanlagtAnkomsttid TIME NOT NULL,
    PlanlagtAvgangstid TIME NOT NULL,
    BudsjettPris INTEGER NOT NULL,
    Økonomipris INTEGER NOT NULL,
    PremiumPris INTEGER NOT NULL,
    Flyrutenummer VARCHAR(50) NOT NULL,
    FlyplassFra VARCHAR(50) NOT NULL,
    FlyplassTil VARCHAR(50) NOT NULL,
    CONSTRAINT Delreisenummer_pk PRIMARY KEY (Delreisenummer),
    CONSTRAINT Flyrutenummer_fk FOREIGN KEY (Flyrutenummer) REFERENCES Flyrute(Flyrutenummer),
    CONSTRAINT FlyplassFra_fk FOREIGN KEY (FlyplassFra) REFERENCES Flyplass(Flyplasskode),
    CONSTRAINT FlyplassTil_fk FOREIGN KEY (FlyplassTil) REFERENCES Flyplass(Flyplasskode)
);

-- Opprettelse av Kunde-tabellen
CREATE TABLE Kunde (
    KundeID INTEGER,
    Navn VARCHAR(255) NOT NULL,
    Tlf VARCHAR(50) NOT NULL,
    Epost VARCHAR(255) NOT NULL,
    Nasjonalitet VARCHAR(50) NOT NULL,
    CONSTRAINT KundeID_pk PRIMARY KEY (KundeID)
);

-- Opprettelse av DelreiseBillett-tabellen
CREATE TABLE DelreiseBillett (
    BillettID INTEGER NOT NULL,
    Kjøpspris INTEGER NOT NULL,
    Billettkategori VARCHAR(50) NOT NULL,
    Referansenummer VARCHAR(50) NOT NULL,
    KundeNr INTEGER NOT NULL,
    CONSTRAINT BillettID_pk PRIMARY KEY (BillettID),
    CONSTRAINT Referansenummer_fk FOREIGN KEY (Referansenummer) REFERENCES Billettkjøp(Referansenummer),
    CONSTRAINT Check_Bilettkategori CHECK (Billettkategori IN ('Økonomi', 'Premium', 'Budsjett')),
    CONSTRAINT KundeNr_fk FOREIGN KEY (KundeNr) REFERENCES Kunde(KundeID) ON DELETE CASCADE
);

-- Opprettelse av Delflyvningsbillett-tabellen
CREATE TABLE Delflyvningsbillett (
    DelflyvningbillettID INTEGER,
    BillettID INTEGER NOT NULL,
    DelFlyvningID INTEGER NOT NULL,
    CONSTRAINT DelflyvningbillettID_pk PRIMARY KEY (DelflyvningbillettID),
    CONSTRAINT BillettID_fk FOREIGN KEY (BillettID) REFERENCES DelreiseBillett(BillettID),
    CONSTRAINT DelFlyvningID_fk FOREIGN KEY (DelFlyvningID) REFERENCES DelFlyvning(DelflyvningsID)
);

-- Opprettelse av FlyvningBillett-tabellen
CREATE TABLE FlyvningBillett (
    FlyvningbillettID INTEGER,
    BillettID INTEGER NOT NULL,
    Løpenummer INTEGER NOT NULL,
    Flyrutenummer VARCHAR(50) NOT NULL,
    CONSTRAINT FlyvningbillettID_pk PRIMARY KEY (FlyvningbillettID),
    CONSTRAINT BillettID_fk FOREIGN KEY (BillettID) REFERENCES DelreiseBillett(BillettID),
    CONSTRAINT Flyvning_fk FOREIGN KEY (Løpenummer, Flyrutenummer) REFERENCES Flyvning(Løpenummer, Flyrutenummer)
);

-- Opprettelse av InnsjekketBagasje-tabellen
CREATE TABLE InnsjekketBagasje (
    Regnummer INTEGER,
    Vekt INTEGER NOT NULL,
    Innleveringstidspunkt TIME NOT NULL,
    BillettID INTEGER NOT NULL,
    CONSTRAINT Regnummer_pk PRIMARY KEY (Regnummer),
    CONSTRAINT BillettID_fk FOREIGN KEY (BillettID) REFERENCES DelreiseBillett(BillettID)
);

-- Opprettelse av Innsjekking-tabellen
CREATE TABLE Innsjekking (
    Innsjekkingsreferanse INTEGER,
    Tidspunkt TIME NOT NULL,
    BillettID INTEGER NOT NULL,
    CONSTRAINT Innsjekkingsreferanse_pk PRIMARY KEY (Innsjekkingsreferanse),
    CONSTRAINT BillettID_fk FOREIGN KEY (BillettID) REFERENCES DelreiseBillett(BillettID)
);

-- Opprettelse av Fordelsprogram-tabellen
CREATE TABLE Fordelsprogram (
    Flyselskapskode VARCHAR(50),
    FordelsprogramNavn VARCHAR(100) NOT NULL,
    CONSTRAINT Flyselskapskode_pk PRIMARY KEY (Flyselskapskode),
    CONSTRAINT Flyselskapskode_fk FOREIGN KEY (Flyselskapskode) REFERENCES Flyselskap(Flyselskapskode)
);

-- Opprettelse av Billettkjøp-tabellen
CREATE TABLE Billettkjøp (
    Referansenummer VARCHAR(50),
    KundeNr INTEGER NOT NULL,
    TotalKjøpspris INTEGER NOT NULL,
    KjøpsDato DATE NOT NULL,
    TurRetur BOOLEAN NOT NULL,
    CONSTRAINT Referansenummer_pk PRIMARY KEY (Referansenummer),
    CONSTRAINT KundeNr_fk FOREIGN KEY (KundeNr) REFERENCES Kunde(KundeID) ON DELETE CASCADE
);

-- Opprettelse av Mellomlandinger-tabellen
CREATE TABLE Mellomlandinger (
    Flyrutenummer VARCHAR(50) NOT NULL,
    FlyplassKode VARCHAR(50) NOT NULL,
    PlanlagtAvgangstid TIME NOT NULL,
    PlanlagtAnkomsttid TIME NOT NULL,
    CONSTRAINT Mellomlandinger_pk PRIMARY KEY (Flyrutenummer, FlyplassKode),
    CONSTRAINT Flyrutenummer_fk FOREIGN KEY (Flyrutenummer) REFERENCES Flyrute(Flyrutenummer),
    CONSTRAINT FlyplassKode_fk FOREIGN KEY (FlyplassKode) REFERENCES Flyplass(Flyplasskode)
);

-- Opprettelse av MedlemAv-tabellen
CREATE TABLE MedlemAv (
    KundeID INTEGER NOT NULL,
    Flyselskapskode VARCHAR(50) NOT NULL,
    CONSTRAINT MedlemAv_pk PRIMARY KEY (KundeID, Flyselskapskode),
    CONSTRAINT KundeID_fk FOREIGN KEY (KundeID) REFERENCES Kunde(KundeID) ON DELETE CASCADE,
    CONSTRAINT Flyselskapskode_fk FOREIGN KEY (Flyselskapskode) REFERENCES Fordelsprogram(Flyselskapskode)
);

-- Opprettelse av EkteTid-tabellen
CREATE TABLE EkteTid (
    Flyrutenummer VARCHAR(50) NOT NULL,
    Løpenummer INTEGER NOT NULL,
    FlyplassKode VARCHAR(50) NOT NULL,
    AnkomstTid TIME,
    AvgangsTid TIME,
    CONSTRAINT EkteTid_pk PRIMARY KEY (Flyrutenummer, Løpenummer, FlyplassKode),
    CONSTRAINT Flyrutenummer_fk FOREIGN KEY (Flyrutenummer) REFERENCES Flyrute(Flyrutenummer),
    CONSTRAINT Løpenummer_fk FOREIGN KEY (Løpenummer) REFERENCES Flyvning(Løpenummer),
    CONSTRAINT FlyplassKode_fk FOREIGN KEY (FlyplassKode) REFERENCES Flyplass(Flyplasskode)
);