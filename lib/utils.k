shortHash = lambda s: str -> str {
    lenStr = str(len(s))
    s if len(s) <= 7 else "${lenStr}${s[:2]}${s[-2:]}"
}

schema OwnerLabels:
    application: str
    instance: str
    component: str
    partOf?: str
    extra?: {str:str}

schema ResourceLabels:
    resourceKind: str
    resourceName: str
    resourceNamespace: str

labelMap = {
    application = "app.kubernetes.io/name"
    instance = "app.kubernetes.io/instance"
    component = "app.kubernetes.io/component"
    partOf = "app.kubernetes.io/part-of"
    resourceKind = "auth.versa-stack.io/resource"
    resourceName = "auth.versa-stack.io/resource-name"
    resourceNamespace = "auth.versa-stack.io/resource-namespace"
}

makeOwnerLabels = lambda config: OwnerLabels -> {str:str} {
    {
        "${labelMap.application}" = config.application
        "${labelMap.instance}" = config.instance
        "${labelMap.component}" = config.component
        "${labelMap.partOf}" = config.partOf
        **(config.extra or {})
    }
}

makeResourceLabels = lambda name: str, instance: str, namespace: str -> {str:str} {
    {
        "${labelMap.resourceKind}" = name
        "${labelMap.resourceName}" = instance
        "${labelMap.resourceNamespace}" = namespace
    }
}
