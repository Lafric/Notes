flowchart LR
subgraph NET["Réseau de l’entreprise"]
U["Utilisateurs internes"]
DNS["DNS Intranet<br/>mpmx.company.local"]

        subgraph VM["VM mpmX"]
            RP["Reverse Proxy<br/>HTTPS : 443"]
            FE["Frontend mpmX"]
            BE["Backend mpmX"]
        end

        U --> DNS
        DNS --> RP
        RP --> FE
        FE --> BE
    end

    subgraph AZ["Azure"]
        ENTRA["Microsoft Entra ID<br/>SSO utilisateurs"]

        subgraph DBX["Azure Databricks"]
            CON["Intégration native mpmX<br/>mécanisme à confirmer"]
            SQL["SQL Warehouse / Compute"]
            UC["Unity Catalog"]
            DATA["Tables et volumes"]
        end
    end

    FE -. Authentification .-> ENTRA
    BE -->|"HTTPS 443<br/>Service Principal + OAuth"| CON
    CON --> SQL
    SQL --> UC
    UC --> DATA
