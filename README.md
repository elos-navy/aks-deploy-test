# AKS deployment test

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Felos-tech%2Faks-deploy-test%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Felos-tech%2Faks-deploy-test%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

## Zistenie podporovanych verzii kubernetes

Dolezite, pretoze moze nastat error 'The value of parameter orchestratorProfile.OrchestratorVersion is invalid'

```
az aks get-versions --location westeurope --output table
```

## Vytvorenie/zistenie service principal ID/Key

https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal

