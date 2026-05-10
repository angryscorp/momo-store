{{/*
Full release name: combines release name and chart name.
Example: release "staging-backend" + chart "backend" -> "staging-backend"
         release "foo" + chart "backend" -> "foo-backend"
*/}}
{{- define "backend.fullname" -}}
{{- if contains .Chart.Name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Common labels — applied to every object in the chart.
*/}}
{{- define "backend.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end -}}

{{/*
Selector labels — used by Deployment.spec.selector and Service.spec.selector.
MUST be a stable subset of common labels (selectors are immutable after creation).
*/}}
{{- define "backend.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
ServiceAccount name. By default = fullname.
*/}}
{{- define "backend.serviceAccountName" -}}
{{- include "backend.fullname" . -}}
{{- end -}}
