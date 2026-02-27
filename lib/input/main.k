schema VRDInput:
    parent?: any
    inputs?: {str:any}
    observed?: [any]

schema Metadata:
    name: str = ""
    namespace: str = "default"
    labels?: {str:str}
    annotations?: {str:str}

raw_input = option("input") or {}

input: VRDInput = VRDInput {
    parent = raw_input.parent
    inputs = raw_input.inputs
    observed = raw_input.observed
}

parent = input.parent
inputs = input.inputs
observed = input.observed
