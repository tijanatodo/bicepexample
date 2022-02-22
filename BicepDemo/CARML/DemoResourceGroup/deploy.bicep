targetScope = 'subscription'

// ================ //
// Input Parameters //
// ================ //

@description('ResourceGroup input parameter')
param resourceGroupParameters object

@description('Network Security Group input parameter')
param networkSecurityGroupParameters object

@description('Virtual Network input parameter')
param vNetParameters object

// Shared
param location string = deployment().location

// =========== //
// Deployments //
// =========== //

// Resource Group
module rg 'br:adpsxxazacrx001.azurecr.io/bicep/modules/microsoft.resources.resourcegroups:0.0.12' = if(resourceGroupParameters.enabled) {
  name: '${uniqueString(deployment().name, location)}-rg'
  scope: subscription()
  params: {
    resourceGroupName: resourceGroupParameters.name
    location: location
  }
}

// Network Security Group
module nsg 'br:adpsxxazacrx001.azurecr.io/bicep/modules/microsoft.network.networksecuritygroups:0.0.16' = if(networkSecurityGroupParameters.enabled) {
  name: '${uniqueString(deployment().name, location)}-nsg'
  scope: resourceGroup(resourceGroupParameters.name)
  params: {
    networkSecurityGroupName: networkSecurityGroupParameters.name
  }
  dependsOn: [
    rg
  ]
}

// Virtual Network
module vnet 'br:adpsxxazacrx001.azurecr.io/bicep/modules/microsoft.network.virtualnetworks:0.0.13' = if(vNetParameters.enabled) {
  name: '${uniqueString(deployment().name, location)}-vnet'
  scope: resourceGroup(resourceGroupParameters.name)
  params: {
    subnets: vNetParameters.subnets
    vNetAddressPrefixes: vNetParameters.addressPrefix
    name: vNetParameters.name
  }
  dependsOn: [
    rg
    nsg
  ]
}
