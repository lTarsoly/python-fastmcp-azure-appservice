$RESOURCE_GROUP_NAME = "LaszlosPythonWebAppResourceGroup"
$APP_SERVICE_PLAN_NAME = "LaszlosPythonWebAppPlan"
$APP_SERVICE_NAME = "LaszlosPythonWebApp"
$LOCATION = "uksouth"
az group create -l uksouth -n $RESOURCE_GROUP_NAME
az appservice plan create --name $APP_SERVICE_PLAN_NAME --resource-group $RESOURCE_GROUP_NAME --is-linux --location $LOCATION
az webapp create --resource-group $RESOURCE_GROUP_NAME --name $APP_SERVICE_NAME --runtime PYTHON:3.13 --plan $APP_SERVICE_PLAN_NAME

az webapp config appsettings set --resource-group $RESOURCE_GROUP_NAME --name $APP_SERVICE_NAME --settings SCM_DO_BUILD_DURING_DEPLOYMENT="True"
az webapp config set --resource-group $RESOURCE_GROUP_NAME --name $APP_SERVICE_NAME --startup-file "python app.py"
az webapp config set --resource-group $RESOURCE_GROUP_NAME --name $APP_SERVICE_NAME --always-on true

Compress-Archive -Path .\.venv, .\app.py, .\requirements.txt -DestinationPath .\app.zip -Force
az webapp deploy --resource-group $RESOURCE_GROUP_NAME --name $APP_SERVICE_NAME --src-path .\app.zip

Remove-Item .\app.zip -Force