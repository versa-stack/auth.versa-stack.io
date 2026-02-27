import ..lib.input as i
import .model as m
import ..lib.utils

kratos: m.Kratos = i.parent

ownerLabels = utils.makeOwnerLabels(utils.OwnerLabels {
    application = "kratos"
    instance = kratos.metadata.name
    component = "auth"
    partOf = kratos.metadata.labels?["app.kubernetes.io/part-of"]
    extra = utils.makeResourceLabels("kratoses.auth.versa-stack.io", kratos.metadata.name, kratos.metadata.namespace)
})

makeName = lambda name: str -> str {
    hashedParentName = utils.shortHash(kratos.metadata.name)
    "kratos-${hashedParentName}-${name}"
}
