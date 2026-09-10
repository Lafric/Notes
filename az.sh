az login

az group create \
  --name rg-db2-test \
  --location northeurope

az container create \
  --resource-group rg-db2-test \
  --name db2aci \
  --location northeurope \
  --image icr.io/db2_community/db2:12.1.5.0 \
  --os-type Linux \
  --sku Confidential \
  --privileged true \
  --cpu 4 \
  --memory 8 \
  --ip-address Public \
  --ports 50000 \
  --restart-policy Always \
  --environment-variables \
      LICENSE=accept \
      DB2INSTANCE=db2inst1 \
      DBNAME=testdb \
      BLU=false \
      ENABLE_ORACLE_COMPATIBILITY=false \
      UPDATEAVAIL=NO \
      TO_CREATE_SAMPLEDB=false \
      REPODB=false \
      IS_OSXFS=false \
      PERSISTENT_HOME=true \
      HADR_ENABLED=false \
  --secure-environment-variables \
      DB2INST1_PASSWORD='YourStrongTestPassword'  