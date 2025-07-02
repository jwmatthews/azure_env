az ad sp list --all --query "[].{Name:displayName, AppId:appId, ObjectId:objectId}" -o table
