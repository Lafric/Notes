AAG-Grundmodell für Unity Catalog

Wir definieren zunächst Berechtigungsprofile, noch ohne Mapping auf die AUG-Governance-Gruppen.

Namensschema
AAG-DT-[STAGE]-DATABRICKS-[Schutzobjekt]-[Objektname]-[Rechteprofil]

Beispiele:

AAG-DT-DEV-DATABRICKS-Catalog-Analytics-Browse
AAG-DT-DEV-DATABRICKS-Schema-SalesGold-Read
AAG-DT-DEV-DATABRICKS-Schema-SalesSilver-Write
AAG-DT-DEV-DATABRICKS-Schema-SalesGold-Manage

Der konkrete Catalog- oder Schema-Name sollte enthalten sein, weil eine Gruppe sonst nicht erkennen lässt, für welchen Datenbereich sie gilt.

Vorgeschlagene Rechteprofile
Rechteprofil Unity-Catalog-Privilegien Zweck
Browse BROWSE auf Catalog Metadaten und Lineage entdecken, aber keine Daten lesen
Read USE CATALOG, USE SCHEMA, SELECT; optional READ VOLUME Tabellen und Views lesen
Write Rechte aus Read plus MODIFY; bei Bedarf CREATE TABLE, CREATE MATERIALIZED VIEW, CREATE VOLUME, WRITE VOLUME Daten verarbeiten und Datenobjekte erstellen
Manage USE CATALOG, USE SCHEMA, MANAGE plus benötigte Read-/Write-Rechte Berechtigungen verwalten, Ownership übertragen und Objekte administrieren

USE CATALOG und USE SCHEMA sind notwendige Zugangsprivilegien, geben alleine aber noch keinen Zugriff auf Tabellen oder Dateien. Für Tabellenzugriff wird zusätzlich beispielsweise SELECT oder MODIFY benötigt. BROWSE ermöglicht nur die Datenerkennung und Zugriffsanforderung.

Wichtige Besonderheit bei MANAGE

MANAGE erlaubt die Verwaltung von Grants, Ownership und Objekten, erteilt aber nicht automatisch SELECT, MODIFY oder andere Datenrechte. Diese müssen zusätzlich vergeben werden.

Vererbung

Privilegien auf einem Catalog oder Schema gelten auch für die darunterliegenden aktuellen und zukünftigen Objekte. Deshalb sollten breite Rechte möglichst auf dem Schema und nicht pauschal auf dem gesamten Catalog vergeben werden.

Damit haben wir zunächst vier zentrale Unity-Catalog-AAG-Typen:

...-Browse
...-Read
...-Write
...-Manage

Im nächsten Schritt können wir entscheiden, welche konkreten Catalogs und Schemas diese AAGs benötigen.

1. AAGs für Workspace-Entitlements

Aktuell unterscheidet Databricks insbesondere Consumer access, Databricks SQL access und Workspace access. Zusätzlich gibt es administrative Compute-Entitlements für die uneingeschränkte Cluster- und Pool-Erstellung.

AAG-Gruppe Technisches Entitlement Zweck
AAG-DT-[STAGE]-DATABRICKS-Workspace-ConsumerAccess Consumer access Eingeschränkter Zugang für Business-Nutzer zu freigegebenen Dashboards, Genie Agents und Apps
AAG-DT-[STAGE]-DATABRICKS-Workspace-DatabricksSQLAccess Databricks SQL access Nutzung von SQL Editor, Queries, Dashboards und SQL Warehouses
AAG-DT-[STAGE]-DATABRICKS-Workspace-WorkspaceAccess Workspace access Nutzung von Notebooks, Jobs, Pipelines, Modellen und Data-Engineering-/ML-Funktionen
AAG-DT-[STAGE]-DATABRICKS-Compute-UnrestrictedCreate Allow unrestricted cluster creation Erstellung uneingeschränkter Classic-Compute-Ressourcen und SQL Warehouses
AAG-DT-[STAGE]-DATABRICKS-InstancePool-Create Allow pool creation Erstellung von Instance Pools

Wichtig: Consumer access sollte normalerweise das einzige Access-Entitlement eines reinen Consumers sein. Sobald dieselbe Person zusätzlich Workspace access oder Databricks SQL access erhält, ist sie kein technisch eingeschränkter Consumer mehr.

2. AAGs für Workspace-ACLs

Für ACLs verwenden wir dieses Schema:

AAG-DT-[STAGE]-DATABRICKS-[Schutzobjekt]-[Objektname]-[Permission]

Beispiel:

AAG-DT-DEV-DATABRICKS-Folder-Sales-Edit
AAG-DT-PROD-DATABRICKS-Job-DailySales-ManageRun
AAG-DT-PROD-DATABRICKS-SQLWarehouse-BI-Use
Empfohlene Kern-AAGs
Schutzobjekt Empfohlene AAG-Profile Bedeutung
Folder / Notebook View, Run, Edit, Manage Inhalt ansehen, ausführen, bearbeiten oder Berechtigungen verwalten
Git Folder Read, Run, Edit, Manage Quellcode lesen, ausführen, bearbeiten und Git-Aktionen durchführen
Job View, ManageRun, Manage Lauf überwachen, Lauf starten/abbrechen oder Jobdefinition verwalten
Pipeline View, Run, Manage Pipeline ansehen, Updates starten oder Konfiguration verwalten
Compute Attach, Restart, Manage Notebook anhängen, Compute starten/neustarten oder vollständig administrieren
SQL Warehouse View, Monitor, Use, Manage Warehouse ansehen, überwachen, SQL ausführen oder administrieren
Dashboard View, Run, Edit, Manage Dashboard anzeigen, aktualisieren, bearbeiten oder Berechtigungen verwalten
Query View, Run, Edit, Manage SQL-Abfrage anzeigen, ausführen, bearbeiten oder verwalten

Die Permission-Stufen sind nicht bei allen Schutzobjekten identisch. Jobs verwenden beispielsweise CAN MANAGE RUN, Compute verwendet CAN ATTACH TO und CAN RESTART, während SQL Warehouses CAN MONITOR und CAN USE kennen.

AAG-DT-DEV-DATABRICKS-Folder-Sales-View
AAG-DT-DEV-DATABRICKS-Folder-Sales-Run
AAG-DT-DEV-DATABRICKS-Folder-Sales-Edit
AAG-DT-DEV-DATABRICKS-Folder-Sales-Manage

Pipelines
AAG-DT-PROD-DATABRICKS-Pipeline-SalesMedallion-View
AAG-DT-PROD-DATABRICKS-Pipeline-SalesMedallion-Run
AAG-DT-PROD-DATABRICKS-Pipeline-SalesMedallion-Manage

CAN RUN erlaubt Pipeline-Updates, während CAN MANAGE zusätzlich Konfiguration und Berechtigungen verwalten lässt. Die Datenrechte der Pipeline werden separat über die Run-as-Identität und Unity Catalog bestimmt.

Compute
AAG-DT-DEV-DATABRICKS-Compute-SharedEngineering-Attach
AAG-DT-DEV-DATABRICKS-Compute-SharedEngineering-Restart
AAG-DT-DEV-DATABRICKS-Compute-SharedEngineering-Manage

Attach reicht für normale Entwickler meist aus. Manage erlaubt unter anderem Konfigurationsänderungen, Größenänderungen und die Verwaltung der ACLs.

SQL Warehouse
AAG-DT-PROD-DATABRICKS-SQLWarehouse-BusinessBI-View
AAG-DT-PROD-DATABRICKS-SQLWarehouse-BusinessBI-Monitor
AAG-DT-PROD-DATABRICKS-SQLWarehouse-BusinessBI-Use
AAG-DT-PROD-DATABRICKS-SQLWarehouse-BusinessBI-Manage

CAN USE erlaubt das Ausführen von Queries. Es gewährt aber keine automatischen Datenrechte; dafür sind zusätzlich Unity-Catalog-Privilegien erforderlich.
