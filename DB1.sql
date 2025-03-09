-- *Flyprodusent* - FlyprodusentNavn, Nasjonalitet, Stiftelsesår
CREATE TABLE Flyprodusent (
    FlyprodusentNavn VARCHAR(50),
    Nasjonalitet VARCHAR(50) NOT NULL,
    Stiftelsesår INTEGER NOT NULL,
    constraint FlyprodusentNavn_pk primary key (FlyprodusentNavn)
);

-- kobles til flyprodusent via fly 
-- *Flytype* - FlytypeNavn, Setekonfigurasjon, FørsteProduksjonsår, SisteProduksjonsår
CREATE TABLE Flytype (
    FlytypeNavn VARCHAR(255),
    Setekonfigurasjon VARCHAR(255),
    FørsteProduksjonsår INTEGER NOT NULL,
    SisteProduksjonsår INTEGER,
    constraint FlytypeNavn_pk primary key (FlytypeNavn)
);

-- 4NF ?
-- kobles til flåte via flytype og flyselskap via flyselskapskode
-- *Fly* - Registreringsnummer, FlyNavn, ÅrSattIDrift, FlytypeNavn, FlyprodusentNavn, Serienummer, Flyselskapkode
CREATE TABLE Fly (
    Registreringsnummer VARCHAR(50),
    FlyNavn VARCHAR(50),
    ÅrSattIDrift INTEGER,
    FlytypeNavn VARCHAR(50),
    FlyprodusentNavn VARCHAR(50),
    Serienummer VARCHAR(50),
    Flyselskapkode VARCHAR(50),
    constraint Registreringsnummer_pk primary key (Registreringsnummer),
    constraint Flyselskapskode foreign key (Flyselskapkode) references Flyselskap(Flyselskapskode),
    constraint FlytypeNavn_fk foreign key (FlytypeNavn) references Flytype(FlytypeNavn),
    constraint FlyprodusentNavn_fk foreign key (FlyprodusentNavn) references Flyprodusent(FlyprodusentNavn),
    constraint Serienummer_unique unique (FlyprodusentNavn, Serienummer) -- Ingen flyprodusent kan ha to fly med samme serienummer
);

CREATE TABLE Flyselskap (
    Flyselskapskode VARCHAR(50),
    FlyselskapNavn VARCHAR(50),
    Stiftelsesår INTEGER,
    Nasjonalitet VARCHAR(50),
    constraint Flyselskapskode_pk primary key (Flyselskapskode)
);

-- svak entitet
CREATE TABLE Flåte (
    Flåtenavn VARCHAR(255),
    FlytypeNavn VARCHAR(255),
    Flyselskapskode VARCHAR(255),
    constraint Flåte_pk primary key (FlytypeNavn, Flyselskapskode),
    constraint FlytypeNavn_fk foreign key (FlytypeNavn) references Flytype(FlytypeNavn),
    constraint Flyselskapskode_fk foreign key (Flyselskapskode) references Flyselskap(Flyselskapskode)
);

CREATE TABLE Flyrute (
    Flyrutenummer VARCHAR(255),
    UkedagsKode VARCHAR(255),
    OppstartsDato DATE,
    SluttDato DATE,
    PlanlagtAnkomsttid TIME,
    PlanlagtAvgangstid TIME,
    FlytypeNavn VARCHAR(255),
    Flyselskapskode VARCHAR(255),
    Budsjettpris INTEGER,
    Økonomipris INTEGER,
    Premiumpris INTEGER,
    constraint Flyrutenummer_pk primary key (Flyrutenummer),
    constraint FlytypeNavn_fk foreign key (FlytypeNavn) references Flytype(FlytypeNavn),
    constraint Flyselskapskode_fk foreign key (Flyselskapskode) references Flyselskap(Flyselskapskode)
);

CREATE TABLE Flyvning (
    Løpenummer INTEGER,
    Flyrutenummer VARCHAR(255),
    FlyvningStatus {"Planned","Cancelled", "Completed", "Active"},
    Dato DATE,
    PlanlagtAvgangstid TIME,
    PlanlagtAnkomsttid TIME,
    Registreringsnummer VARCHAR(255),
    constraint Registreringsnummer_fk foreign key (Registreringsnummer) references Fly(Registreringsnummer),
    constraint Løpenummer_pk primary key (Løpenummer),
    constraint Flyrutenummer_fk foreign key (Flyrutenummer) references Flyrute(Flyrutenummer)
);

-- svak entitet, kun ett fordelsprogram per flyselskap
CREATE TABLE Fordelsprogram(
    FordelsprogramNavn VARCHAR(255),
    Flyselskapskode VARCHAR(255),
    constraint Flyselskapskode_fk foreign key (Flyselskapskode) references Flyselskap(Flyselskapskode),
    constraint FordelsprogramNavn_pk primary key (FordelsprogramNavn)
);

CREATE TABLE Kunde(
    KundeID INTEGER,
    Navn VARCHAR(255) NOT NULL,
    Tlf VARCHAR(255) NOT NULL,
    Epost VARCHAR(255) NOT NULL,
    Nasjonalitet VARCHAR(255) NOT NULL,
    constraint KundeID_pk primary key (KundeID)
);

-- mange til mange tabell
CREATE TABLE MedlemAv(
    KundeID INTEGER,
    Flyselskapskode VARCHAR(255),
    constraint MedlemAv_pk primary key (KundeID, Flyselskapskode),
    constraint KundeID_fk foreign key (KundeID) references Kunde(KundeID),
    constraint Flyselskapskode_fk foreign key (Flyselskapskode) references Flyselskap(Flyselskapskode)
);

CREATE TABLE DelreiseBillett(
    BillettID INTEGER,
    Kjøpsdato DATE,
    Referansenummer VARCHAR(255),
    constraint BillettID_pk primary key (BillettID)
    constraint Referansenummer_fk foreign key (Referansenummer) references FlyvningBillett(Referansenummer)
);

CREATE TABLE DelFlyvningBillett(
    DelFlyvningBillettID INTEGER,
    TotalPris INTEGER,
    constraint DelFlyvningBillettID_pk primary key (DelFlyvningBillettID)
);

CREATE TABLE FlyvningBillett(
    FlyvningBillettID INTEGER,
    TotalPris INTEGER,
    constraint BillettID_fk foreign key (BillettID) references DelreiseBillett(BillettID)
);

CREATE TABLE BillettKjoep(
    TotalKjoepsPris INTEGER,
    Referansenummer VARCHAR(255),
    Dato DATE,
    TurRetur BOOLEAN,
    constraint Referansenummer_pk primary key (Referansenummer)
);

CREATE TABLE Innsjekking(
    BillettID INTEGER,
    Tidspunkt TIME,
    constraint BillettID_fk foreign key (BillettID) references DelreiseBillett(BillettID)
    constraint BillettID_pk primary key (BillettID)
);

CREATE TABLE Bagasje(
    Regnummer INTEGER,
    Vekt INTEGER,
    Innleveringstidspunkt TIME,
    BillettID INTEGER,
    constraint BillettID_fk foreign key (BillettID) references DelreiseBillett(BillettID)
    constraint Regnummer_pk primary key (Regnummer)
);

CREATE TABLE Sete(
    SeteID INTEGER,
    Rad INTEGER,
    BillettID INTEGER,
    FlytypeNavn VARCHAR(255),
    FlytypeNavn VARCHAR(255),
    constraint SeteID_pk primary key (SeteID)
    constraint BillettID_fk foreign key (BillettID) references DelreiseBillett(BillettID)
    constraint FlytypeNavn_fk foreign key (FlytypeNavn) references Flytype(FlytypeNavn)
);

CREATE TABLE SeteValg(
    SeteID INTEGER,
    DelFlyvningID INTEGER,
    BillettID INTEGER,
    constraint SeteID_fk foreign key (SeteID) references Sete(SeteID)
    constraint DelFlyvningID_fk foreign key (DelFlyvningID) references DelFlyvning(DelFlyvningID)
    constraint BillettID_fk foreign key (BillettID) references DelreiseBillett(BillettID)
    constraint SeteID_pk primary key (SeteID, DelFlyvningID, BillettID)
);

CREATE TABLE DelFlyvning(
    DelFlyvningID INTEGER,
    DelFlyvningStatus {"Planned","Cancelled", "Completed", "Active"},
    PlanlagtAnkomsttid TIME,
    PlanlagtAvgangstid TIME,
    constraint DelFlyvningID_pk primary key (DelFlyvningID)
);

CREATE TABLE DelReise(
    DelReiseID INTEGER,
    BillettKateogri {"Økonomi", "Premium", "Budsjett"},
    Økonomipris INTEGER,
    Premiumpris INTEGER,
    Budsjettpris INTEGER,
    constraint DelReiseID_pk primary key (DelReiseID)
);