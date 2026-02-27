import ..config as c

spec = c.kratos.spec
dbName = c.makeName("db")
dbSecretName = dbName + "-conn-credential" if spec.database else None

cluster = {
    apiVersion = "apps.kubeblocks.io/v1"
    kind = "Cluster"
    metadata = {
        name = dbName
        namespace = c.kratos.metadata.namespace
        labels = c.ownerLabels
    }
    spec = {
        terminationPolicy = "WipeOut"
        clusterDef = spec.database.engine
        if spec.database?.topology:
            topology = spec.database.topology
        componentSpecs = [{
            name = spec.database.engine
            if spec.database?.version:
                serviceVersion = spec.database.version
            replicas = spec.database?.replicas or 1
            resources = spec.database?.resources or {
                limits: {cpu = "0.5", memory = "0.5Gi"}
                requests: {cpu = "0.5", memory = "0.5Gi"}
            }
            volumeClaimTemplates = [{
                name = "data"
                spec = {
                    if spec.database?.storageClassName:
                        storageClassName = spec.database.storageClassName
                    accessModes = ["ReadWriteOnce"]
                    resources = {requests = {storage = spec.database?.storage or "10Gi"}}
                }
            }]
        }]
    }
} if spec.database else None

items = [cluster] if cluster else []
