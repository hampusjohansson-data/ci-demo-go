1. Projektets syfte och mål
Målet med detta projekt är att:

* Visa hur man kan bygga och testa två olika tjänster (en i Go och en i Python) i samma CI/CD-pipeline.

* Använda en gemensam databas (PostgreSQL) som båda tjänsterna kan kommunicera med.
Automatisera hela flödet från kodändring till färdig applikation genom GitHub Actions.

* Integrera grundläggande cybersäkerhet i varje steg av processen: testning, versionshantering, kodanalys, sårbarhetsskanning och signering.

* Projektet kan användas både som en mall för nya projekt och som utbildningsmaterial i hur CI/CD fungerar i praktiken.

2. Översikt över komponenterna
2.1 Go-tjänsten
* Skriven i programmeringsspråket Go (Golang).

* Har en enkel HTTP-server som svarar på förfrågningar (REST API).

* Testas automatiskt vid varje förändring genom go test.

* Byggs till en kompakt Docker-image (statisk binär, utan beroenden).

2.2 Python-tjänsten
* Skriven i Python med ramverket FastAPI.

* Har motsvarande funktionalitet som Go-tjänsten, men används för att visa hur flera språk kan samverka.

* Testas automatiskt via pytest.

* Körs i en separat Docker-container med en begränsad användare (icke-root).

2.3 PostgreSQL-databasen
* En öppen relationsdatabas som lagrar data åt båda tjänsterna.

* Startas automatiskt via Docker Compose.

* Initieras med ett SQL-skript (init.sql) samt eventuella migreringsfiler i mappen db/migrations/.

2.4 CI/CD-systemet (GitHub Actions)
* Automatiskt system som kör varje gång ny kod laddas upp till GitHub.

* Hanterar följande:

* Testning av koden
* Bygg av Docker-bilder

* Kontroll av att allt fungerar i en tillfällig miljö

* Publicering till GitHub Container Registry (GHCR)

* Allt styrs via en YAML-fil: .github/workflows/ci.yml.

2.5 Docker och Docker Compose

* Docker används för att skapa isolerade miljöer där tjänsterna kan köras oberoende av operativsystem.

* Docker Compose samlar flera containrar (Go-tjänst, Python-tjänst och databas) i en och samma konfiguration.

* Filer:

* Dockerfile – beskriver hur Go-tjänstens container byggs.

* pyservice/Dockerfile – beskriver hur Python-tjänstens container byggs.

* docker-compose.yml – beskriver hur alla tjänster startas tillsammans.

3. Projektets struktur

ci-demo-go/
├── cmd/server/             - Källkod för Go-tjänsten
├── internal/http/          - Hanterar HTTP-förfrågningar (Go)
├── pyservice/              - Källkod för Python-tjänsten
│   ├── app.py              - Huvudprogram för FastAPI
│   ├── tests/              - Tester för Python-delen
│   └── requirements.txt    - Lista över Python-bibliotek
├── db/
│   ├── init.sql            - Grundläggande databasinitiering
│   └── migrations/         - Filer för databasuppdateringar
├── Dockerfile              - Byggfil för Go-tjänsten
├── docker-compose.yml      - Kör miljön lokalt eller i CI
├── Makefile                - Samlade kommandon för test och bygg
├── .github/workflows/ci.yml - Automatiserad CI/CD-pipeline
└── README.md               - Dokumentation (den här filen)

4. Hur flödet fungerar i praktiken

4.1 Lokalt arbete

Utvecklaren skriver kod lokalt, kör tester och bygger containrar med:
make test          # Kör alla Go-tester
make test-py       # Kör Python-tester
docker compose up  # Startar alla tjänster i bakgrunden

När allt fungerar pushas koden till GitHub.

4.2 Automatiska steg i GitHub Actions
När ny kod laddas upp till GitHub startar CI/CD-flödet: 
1. Unit tests (Go)
Kör go test och rapporterar om något misslyckas.
2. Unit tests (Python)
Kör pytest för att verifiera Python-delen.
3. Build images
Bygger Docker-bilder för båda tjänsterna.
4. Docker Compose migration + smoke test
Startar hela miljön (Go, Python, databas), kör databas-migreringar och testar att båda tjänsterna svarar.
5. Publish images to GHCR
Publicerar de färdiga bilderna till GitHub Container Registry om allt fungerar.

Dessa steg visas i GitHub Actions under fliken Actions i projektet.

5. Säkerhetsåtgärder
Projektet innehåller flera lager av säkerhet:

5.1 Branch-skydd
* Endast godkända pull requests får ändra huvudgrenen main.

* Alla tester och bygg måste vara godkända innan kod kan slås ihop.

* Kräver kodgranskning innan sammanslagning.

5.2 Hantering av hemligheter
* Lösenord och API-nycklar lagras aldrig i koden.

* Istället används miljövariabler (.env) som inte checkas in i Git.

* .env.example visar vilka variabler som behövs utan att avslöja riktiga värden.

5.3 Containersäkerhet
* Båda applikationerna körs som icke-root-användare.

* Filer är skrivskyddade (read_only: true) i containern.

* security_opt: no-new-privileges:true hindrar att processen får fler rättigheter än nödvändigt.

5.4 Automatiska säkerhetsskanningar (i nästa nivå)

* Gitleaks kontrollerar att inga lösenord hamnat i Git-historiken.

* Trivy söker efter kända sårbarheter i kod och images.

* CodeQL analyserar koden för osäkra mönster.

* Cosign signerar Docker-bilder digitalt för att verifiera äkthet.

* Dependabot uppdaterar beroenden när nya säkerhetsversioner släpps.

6. Hur man kör projektet lokalt
Installera Docker och Docker Compose.
Klona projektet:
git clone https://github.com/<ditt-användarnamn>/ci-demo-go.git

cd ci-demo-go

Starta miljön:
docker compose up -d

Kör databas-migreringar:
docker compose run --rm migrate

Kontrollera att allt fungerar:
curl http://localhost:8080/health
curl http://localhost:8000/health

Stoppa allt:
docker compose down -v

8. Sammanfattning
Det här projektet är ett komplett exempel på hur man:

* bygger och testar flera tjänster i olika språk i samma pipeline

* integrerar databasmigreringar och automatiska tester

* bygger in säkerhet direkt i utvecklingsflödet

* gör processen repeterbar, spårbar och transparent

Resultatet är ett säkert, automatiserat och lättförståeligt system som visar hur professionell mjukvaruutveckling fungerar i praktiken.
