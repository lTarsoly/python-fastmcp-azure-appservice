$RESOURCE_GROUP_NAME = "LaszlosPythonWebAppResourceGroup"
$APP_SERVICE_PLAN_NAME = "LaszlosPythonWebAppPlan"
$APP_SERVICE_NAME = "LaszlosPythonWebApp"
$LOCATION = "uksouth"

Write-Output "Starting deployment process..."

if ((az group list --query "[?name=='$RESOURCE_GROUP_NAME']") -eq "[]") {
    Write-Output "Creating Resource Group: $RESOURCE_GROUP_NAME"
    az group create -l uksouth -n $RESOURCE_GROUP_NAME
}
else {
    Write-Output "Resource Group $RESOURCE_GROUP_NAME already exists."
}

if ((az appservice plan list --resource-group $RESOURCE_GROUP_NAME --query "[?name=='$APP_SERVICE_PLAN_NAME']") -eq "[]") {
    Write-Output "Creating App Service Plan: $APP_SERVICE_PLAN_NAME"
    az appservice plan create --name $APP_SERVICE_PLAN_NAME --resource-group $RESOURCE_GROUP_NAME --is-linux --location $LOCATION
}
else {
    Write-Output "App Service Plan $APP_SERVICE_PLAN_NAME already exists."
}

if ((az webapp list --resource-group $RESOURCE_GROUP_NAME --query "[?name=='$APP_SERVICE_NAME']") -eq "[]") {
    Write-Output "Creating Web App: $APP_SERVICE_NAME"
    az webapp create --resource-group $RESOURCE_GROUP_NAME --name $APP_SERVICE_NAME --runtime PYTHON:3.13 --plan $APP_SERVICE_PLAN_NAME
}
else {
    Write-Output "Web App $APP_SERVICE_NAME already exists."
}

write-Output "Configuring Web App settings..."
az webapp config appsettings set --resource-group $RESOURCE_GROUP_NAME --name $APP_SERVICE_NAME --settings SCM_DO_BUILD_DURING_DEPLOYMENT="True"
az webapp config set --resource-group $RESOURCE_GROUP_NAME --name $APP_SERVICE_NAME --startup-file "python app.py"
az webapp config set --resource-group $RESOURCE_GROUP_NAME --name $APP_SERVICE_NAME --always-on true

Write-Output "Deploying application..."
Compress-Archive -Path .\.venv, .\app.py, .\requirements.txt -DestinationPath .\app.zip -Force
az webapp deploy --resource-group $RESOURCE_GROUP_NAME --name $APP_SERVICE_NAME --src-path .\app.zip

write-Output "Cleaning up..."
Remove-Item .\app.zip -Force