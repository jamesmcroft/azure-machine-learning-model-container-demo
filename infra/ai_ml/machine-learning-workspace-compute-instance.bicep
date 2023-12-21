@export()
type computeAssignedUserInfo = {
  @description('Users Entra (AAD) object ID.')
  objectId: string
  @description('Users Entra (AAD) tenant ID. Defaults to the current tenant.')
  tenantId: string?
}

@export()
type computeScheduleInfo = {
  @description('Compute power state.')
  action: 'Stop' | 'Start'
  @description('NCrontab format expression for the days/times to run the schedule. Must contain only 5 fields (minute, hour, day of month, month, and day of week).')
  cronExpression: string
  @description('Value indicating whether the schedule is enabled.')
  status: 'Disabled' | 'Enabled'
}

@export()
type computeScriptInfo = {
  @description('The base64 data of the script to run on the compute instance.')
  scriptData: string
  @description('The command line arguments for the script.')
  arguments: string?
}

@description('Name of the resource.')
param name string
@description('Location to deploy the resource. Defaults to the location of the resource group.')
param location string = resourceGroup().location
@description('Tags for the resource.')
param tags object = {}

@description('Name of the AI/ML workspace associated with the compute instance.')
param workspaceName string
@description('Time before the compute instance is shut down due to inactivity. The value should be in ISO 8601 format. Defaults to 15 minutes.')
param idleTimeBeforeShutdown string = 'PT15M' // 15 minutes in ISO 8601 format
@description('Information about the user assigned to the compute instance.')
param assignedUser computeAssignedUserInfo
@description('Information about the startup/shutdown schedule for the compute instance.')
param schedules computeScheduleInfo[]
@description('Information about the creation script to run on the compute instance initial creation.')
param creationScript computeScriptInfo?
@description('Information about the startup script to run on the compute instance each time it starts.')
param startupScript computeScriptInfo?
@description('The VM size of the compute instance. Defaults to Standard_E4ds_v4 (for datasets 1-10GB).')
param vmSize string = 'Standard_E4ds_v4'

resource workspace 'Microsoft.MachineLearningServices/workspaces@2023-06-01-preview' existing = {
  name: workspaceName

  resource workspaceCompute 'computes' = {
    name: name
    location: location
    tags: tags
    properties: {
      computeType: 'ComputeInstance'
      properties: {
        computeInstanceAuthorizationType: 'personal'
        idleTimeBeforeShutdown: idleTimeBeforeShutdown
        personalComputeInstanceSettings: {
          assignedUser: {
            objectId: assignedUser.objectId
            tenantId: assignedUser.tenantId == null ? tenant().tenantId : assignedUser.tenantId!
          }
        }
        schedules: {
          computeStartStop: [for schedule in schedules: {
            action: schedule.action
            cron: {
              expression: schedule.cronExpression
            }
            status: schedule.status
            triggerType: 'Cron'
          }]
        }
        setupScripts: {
          scripts: {
            creationScript: creationScript == null ? null : {
              scriptSource: 'inline'
              scriptData: creationScript.scriptData
              scriptArguments: creationScript.arguments
            }
            startupScript: startupScript == null ? null : {
              scriptSource: 'inline'
              scriptData: startupScript.scriptData
              scriptArguments: startupScript.arguments
            }
          }
        }
        vmSize: vmSize
      }
    }
  }
}

@description('The deployed ML workspace compute resource.')
output resource resource = workspace::workspaceCompute
@description('ID for the deployed ML workspace compute resource.')
output id string = workspace::workspaceCompute.id
@description('Name for the deployed ML workspace compute resource.')
output name string = workspace::workspaceCompute.name
