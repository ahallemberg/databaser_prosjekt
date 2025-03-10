-- Opprettelse av Flyprodusent-tabellen
CREATE TABLE Flyprodusent (
    FlyprodusentNavn VARCHAR(50),
    Nasjonalitet VARCHAR(50) NOT NULL,
    Stiftelsesår INTEGER NOT NULL,
    constraint Flyprodusent_pk primary key (FlyprodusentNavn)
);

-- Opprettelse av Flytype-tabellen
CREATE TABLE Flytype (
    FlytypeNavn VARCHAR(50),
    FørsteProduksjonsår INTEGER NOT NULL,
    SisteProduksjonsår INTEGER,
    constraint Flytype_pk primary key (FlytypeNavn)
);

-- Opprettelse av Rad-tabellen
CREATE TABLE Rad (
    RadNr INTEGER,
    ErNødutgang BOOLEAN NOT NULL
    constraint Rad_pk primary key (RadNr)
);

-- Opprettelse av Sete-tabellen
CREATE TABLE Sete (
    SeteID INTEGER,
    SetePosisjon VARCHAR(1) NOT NULL,
    RadNr INTEGER NOT NULL,
    constraint Sete_fk foreign key (RadNr) references Rad(RadNr)
    constraint Sete_pk primary key (SeteID)
);

-- Opprettelse av SeteValg-tabellen
CREATE TABLE SeteValg (
    SeteID INTEGER,
    DelFlyvningID INTEGER,
    BillettID INTEGER,
    constraint SeteValg_pk primary key (SeteID, DelFlyvningID),
    constraint SeteValg_fk foreign key (SeteID) references Sete(SeteID),
    constraint DelFlyvning_fk foreign key (DelFlyvningID) references DelFlyvning(DelFlyvningID),
    constraint Billett_fk foreign key (BillettID) references DelreiseBillett(BillettID)
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
    constraint Fly_pk primary key (Registreringsnummer),
    constraint FlytypeNavn_pk foreign key (FlytypeNavn) references Flytype(FlytypeNavn),
    constraint FlyprodusentNavn_fk foreign key (FlyprodusentNavn) references Flyprodusent(FlyprodusentNavn),
    constraint Flyselskapskode_fk foreign key (Flyselskapskode) references Flyselskap(Flyselskapskode)
);

-- Opprettelse av Flyselskap-tabellen
CREATE TABLE Flyselskap (
    Flyselskapskode VARCHAR(50),
    FlyselskapsNavn VARCHAR(50) NOT NULL,
    Stiftelsesår INTEGER NOT NULL,
    Nasjonalitet VARCHAR(50) NOT NULL
    constraint Flyselskap_pk primary key (Flyselskapskode)
);

-- Opprettelse av Flåte-tabellen
CREATE TABLE Flåte (
    Flåtenavn VARCHAR(50) NOT NULL,
    FlytypeNavn VARCHAR(50),
    Flyselskapskode VARCHAR(50),
    constraint Flåte_pk primary key (FlytypeNavn, Flyselskapskode),
    constraint FlytypeNavn_fk foreign key (FlytypeNavn) references Flytype(FlytypeNavn),
    constraint Flyselskapskode_fk foreign key (Flyselskapskode) references Flyselskap(Flyselskapskode)
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
    PlanlagtAnkomsttid TIME GENERATED ALWAYS AS (
        (SELECT MAX(PlanlagtAnkomsttid) FROM Delreise WHERE Delreise.Flyrutenummer = Flyrute.Flyrutenummer)
    ) STORED,
    PlanlagtAvgangstid TIME GENERATED ALWAYS AS (
        (SELECT MIN(PlanlagtAvgangstid) FROM Delreise WHERE Delreise.Flyrutenummer = Flyrute.Flyrutenummer)
    ) STORED,
    Budsjettpris INTEGER GENERATED ALWAYS AS (
        (SELECT SUM(BudsjettPris) FROM Delreise WHERE Delreise.Flyrutenummer = Flyrute.Flyrutenummer)
    ) STORED,
    Økonomipris INTEGER GENERATED ALWAYS AS (
        (SELECT SUM(Økonomipris) FROM Delreise WHERE Delreise.Flyrutenummer = Flyrute.Flyrutenummer)
    ) STORED,
    Premiumpris INTEGER GENERATED ALWAYS AS (
        (SELECT SUM(Premiumpris) FROM Delreise WHERE Delreise.Flyrutenummer = Flyrute.Flyrutenummer)
    ) STORED,
    constraint Flyrute_pk primary key (Flyrutenummer),
    constraint FlytypeNavn_fk foreign key (FlytypeNavn) references Flytype(FlytypeNavn),
    constraint Flyselskapskode_fk foreign key (Flyselskapskode) references Flyselskap(Flyselskapskode),
    constraint Startflyplass_fk foreign key (Startflyplass) references Flyplass(Flyplasskode),
    constraint Endeflyplass_fk foreign key (Endeflyplass) references Flyplass(Flyplasskode)
);

-- Opprettelse av Flyplass-tabellen
CREATE TABLE Flyplass (
    Flyplasskode VARCHAR(50),
    Flyplassnavn VARCHAR(100) NOT NULL
    constraint Flyplass_pk primary key (Flyplasskode)
);

-- Opprettelse av Flyvning-tabellen
CREATE TABLE Flyvning (
    Løpenummer INTEGER,
    Flyrutenummer VARCHAR(50),
    FlyvningStatus VARCHAR(50),
    CHECK(FlyvningStatus IN('Planned', 'Cancelled', 'Completed', 'Active')),
    Dato DATE NOT NULL,
    PlanlagtAvgangstid TIME NOT NULL,
    PlanlagtAnkomststid TIME NOT NULL,
    Registreringsnummer VARCHAR(50) NOT NULL,
    constraint Flyvning_pk primary key (Løpenummer, Flyrutenummer),
    UNIQUE (Flyrutenummer, Dato),
    constraint Flyrutenummer_fk foreign key (Flyrutenummer) references Flyrute(Flyrutenummer),
    constraint Registreringsnummer_fk foreign key (Registreringsnummer) references Fly(Registreringsnummer)
);

-- Opprettelse av DelFlyvning-tabellen
CREATE TABLE DelFlyvning (
    DelflyvningsID INTEGER,
    Delreisenummer INTEGER NOT NULL,
    Løpenummer INTEGER NOT NULL,
    Flyrutenummer VARCHAR(50) NOT NULL,
    DelFlyvningStatus VARCHAR(50) GENERATED ALWAYS AS (
        (SELECT FlyvningStatus FROM Flyvning WHERE Flyvning.Løpenummer = DelFlyvning.Løpenummer)
    ) STORED,
    PlanlagtAnkomsttid TIME NOT NULL,
    PlanlagtAvgangstid TIME NOT NULL,
    constraint DelFlyvningsID_pk primary key (DelflyvningsID),
    constraint Delreisenummer_fk foreign key (Delreisenummer) references DelReise(Delreisenummer),
    constraint Løpenummer_fk foreign key (Løpenummer) references Flyvning(Løpenummer),
    constraint Flyrutenummer_fk foreign key (Flyrutenummer) references Flyrute(Flyrutenummer)
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
    constraint Delreisenummer_pk primary key (Delreisenummer),
    constraint Flyrutenummer_fk foreign key (Flyrutenummer) references Flyrute(Flyrutenummer),
    constraint FlyplassFra_fk foreign key (FlyplassFra) references Flyplass(Flyplasskode),
    constraint FlyplassTil_fk foreign key (FlyplassTil) references Flyplass(Flyplasskode)
);

-- Opprettelse av Kunde-tabellen
CREATE TABLE Kunde (
    KundeID INTEGER,
    Navn VARCHAR(255) NOT NULL,
    Tlf VARCHAR(50) NOT NULL,
    Epost VARCHAR(255) NOT NULL,
    Nasjonalitet VARCHAR(50) NOT NULL
    constraint KundeID_pk primary key (KundeID)
);

-- Opprettelse av DelreiseBillett-tabellen
CREATE TABLE DelreiseBillett (
    BillettID INTEGER NOT NULL,
    Kjøpspris INTEGER NOT NULL,
    Billettkategori VARCHAR(50) NOT NULL,
    Referansenummer VARCHAR(50) NOT NULL,
    KundeNr INTEGER NOT NULL,
    constraint BillettID_pk primary key (BillettID),
    constraint Referansenummer_fk foreign key (Referansenummer) REFERENCES Billettkjøp(Referansenummer),
    constraint KundeNr_fk foreign key (KundeNr) REFERENCES Kunde(KundeID)
);
-- Opprettelse av Delflyvningsbillett-tabellen
CREATE TABLE Delflyvningsbillett (
    DelflyvningbillettID INTEGER primary key,
    BillettID INTEGER NOT NULL,
    DelFlyvningID INTEGER NOT NULL,
    constraint BillettID_fk foreign key (BillettID) references DelreiseBillett(BillettID),
    constraint DelFlyvningID_fk foreign key (DelFlyvningID) references DelFlyvning(DelflyvningsID)
);

-- Opprettelse av FlyvningBillett-tabellen
CREATE TABLE FlyvningBillett (
    FlyvningbillettID INTEGER,
    BillettID INTEGER NOT NULL,
    Løpenummer INTEGER NOT NULL,
    Flyrutenummer VARCHAR(50) NOT NULL,
    constraint FlyvningbillettID_pk primary key (FlyvningbillettID),
    constraint BillettID_fk foreign key (BillettID) references DelreiseBillett(BillettID),
    constraint Løpenummer_fk foreign key (Løpenummer) references Flyvning(Løpenummer),
    constraint Flyrutenummer_fk foreign key (Flyrutenummer) references Flyvning(Flyrutenummer)
);

-- Opprettelse av InnsjekketBagasje-tabellen
CREATE TABLE InnsjekketBagasje (
    Regnummer INTEGER,
    Vekt INTEGER NOT NULL,
    Innleveringstidspunkt TIME NOT NULL,
    BillettID INTEGER NOT NULL,
    constraint Regnummer_pk primary key (Regnummer),
    constraint BillettID_fk foreign key (BillettID) references DelReiseBillett(BillettID)
);

-- Opprettelse av Innsjekking-tabellen
CREATE TABLE Innsjekking (
    Innsjekkingsreferanse INTEGER,
    Tidspunkt TIME NOT NULL,
    BillettID INTEGER NOT NULL,
    constraint Innsjekkingsreferanse_pk primary key (Innsjekkingsreferanse),
    constraint BillettID_fk foreign key (BillettID) references DelReiseBillett(BillettID)
);

-- Opprettelse av Fordelsprogram-tabellen
CREATE TABLE Fordelsprogram (
    Flyselskapskode VARCHAR(50),
    FordelsprogramNavn VARCHAR(100) NOT NULL,
    constraint Flyselskapskode_pk primary key (Flyselskapskode),
    constraint Flyselskapskode_fk foreign key (Flyselskapskode) references Flyselskap(Flyselskapskode)
);

-- Opprettelse av Billettkjøp-tabellen
CREATE TABLE Billettkjøp (
    Referansenummer VARCHAR(50),
    KundeNr INTEGER NOT NULL,
    TotalKjøpspris INTEGER GENERATED ALWAYS AS (
        (SELECT SUM(Kjøpspris) FROM DelReiseBillett WHERE DelReiseBillett.BillettID = Billettkjøp.Referansenummer)
    ) STORED,
    KjøpsDato DATE NOT NULL,
    TurRetur BOOLEAN NOT NULL,
    constraint Billettkjøp_pk primary key (Referansenummer),
    constraint KundeNr_fk foreign key (KundeNr) references Kunde(KundeID)
);

-- Opprettelse av Mellomlandinger-tabellen
CREATE TABLE Mellomlandinger (
    Flyrutenummer VARCHAR(50) NOT NULL,
    FlyplassKode VARCHAR(50) NOT NULL,
    PlanlagtAvgangstid TIME NOT NULL,
    PlanlagtAnkomsttid TIME NOT NULL,
    constraint Mellomlandinger_pk primary key (Flyrutenummer, FlyplassKode),
    constraint Flyrutenummer_fk foreign key (Flyrutenummer) references Flyrute(Flyrutenummer),
    constraint FlyplassKode_fk foreign key (FlyplassKode) references Flyplass(Flyplasskode)
);

-- Opprettelse av MedlemAv-tabellen
CREATE TABLE MedlemAv (
    KundeID INTEGER NOT NULL,
    Flyselskapskode VARCHAR(50) NOT NULL,
    constraint MedlemAv_pk primary key (KundeID, Flyselskapskode),
    constraint KundeID_fk foreign key (KundeID) references Kunde(KundeID),
    constraint Flyselskapskode_fk foreign key (Flyselskapskode) references Fordelsprogram(Flyselskapskode)
);

-- Opprettelse av RadKonfigurasjon-tabellen
CREATE TABLE RadKonfigurasjon (
    RadNr INTEGER NOT NULL,
    FlyTypeNavn VARCHAR(50) NOT NULL,
    constraint RadKonfigurasjon_pk primary key (RadNr, FlyTypeNavn),
    constraint RadNr_fk foreign key (RadNr) references Rad(RadNr),
    constraint FlyTypeNavn_fk foreign key (FlyTypeNavn) references FlyType(FlyTypeNavn)
);

-- Opprettelse av EkteTid-tabellen
CREATE TABLE EkteTid (
    Flyrutenummer VARCHAR(50) NOT NULL,
    Løpenummer INTEGER NOT NULL,
    FlyplassKode VARCHAR(50) NOT NULL,
    AnkomstTid TIME,
    AvgangsTid TIME,
    constraint EkteTid_pk primary key (Flyrutenummer, Løpenummer, FlyplassKode),
    constraint Flyrutenummer_fk foreign key (Flyrutenummer) references Flyrute(Flyrutenummer),
    constraint Løpenummer_fk foreign key (Løpenummer) references Flyvning(Løpenummer),
    constraint FlyplassKode_fk foreign key (FlyplassKode) references Flyplass(Flyplasskode)
);
