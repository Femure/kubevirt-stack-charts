{{/*
Chart name.
*/}}
{{- define "kubevirt-stack.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels applied to all resources.
*/}}
{{- define "kubevirt-stack.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: kubevirt-stack
{{- end }}

{{/*
Resolve image with optional global registry override.
Usage: {{ include "kubevirt-stack.image" (dict "repository" "quay.io/kubevirt/virt-operator" "tag" "v1.8.1" "global" .Values.global) }}
*/}}
{{- define "kubevirt-stack.image" -}}
{{- $registry := "" -}}
{{- if and .global .global.imageRegistry -}}
  {{- $registry = .global.imageRegistry -}}
{{- end -}}
{{- if $registry -}}
  {{- $parts := splitList "/" .repository -}}
  {{- $repoPath := join "/" (rest $parts) -}}
  {{- printf "%s/%s:%s" $registry $repoPath .tag -}}
{{- else -}}
  {{- printf "%s:%s" .repository .tag -}}
{{- end -}}
{{- end }}

{{/*
Global imagePullSecrets.
*/}}
{{- define "kubevirt-stack.imagePullSecrets" -}}
{{- if and .Values.global .Values.global.imagePullSecrets }}
imagePullSecrets:
  {{- range .Values.global.imagePullSecrets }}
  - name: {{ . }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Merge global and component-specific nodeSelector.
Usage: {{ include "kubevirt-stack.nodeSelector" (dict "global" .Values.global.nodeSelector "local" .Values.nhc.nodeSelector) }}
*/}}
{{- define "kubevirt-stack.nodeSelector" -}}
{{- $merged := dict "kubernetes.io/os" "linux" -}}
{{- if .global -}}
  {{- $merged = merge $merged .global -}}
{{- end -}}
{{- if .local -}}
  {{- $merged = merge $merged .local -}}
{{- end -}}
{{- toYaml $merged -}}
{{- end }}

{{/*
Resolve namespace: use .Values.namespace if set, fall back to global.kubevirtNamespace.
*/}}
{{- define "kubevirt-stack.namespace" -}}
{{- if .Values.namespace -}}
  {{- .Values.namespace -}}
{{- else if and .Values.global .Values.global.kubevirtNamespace -}}
  {{- .Values.global.kubevirtNamespace -}}
{{- else -}}
  kubevirt
{{- end -}}
{{- end }}

{{/*
Format Multus additional networks annotation value.
Usage: {{ include "medik8s.multusNetworks" .Values.far.additionalNetworks }}
*/}}
{{- define "medik8s.multusNetworks" -}}
{{- $nets := list -}}
{{- range . -}}
  {{- if .namespace -}}
    {{- $nets = append $nets (printf "%s/%s" .namespace .name) -}}
  {{- else -}}
    {{- $nets = append $nets .name -}}
  {{- end -}}
{{- end -}}
{{- join ", " $nets -}}
{{- end }}

{{/*
Merge global and component-specific tolerations.
*/}}
{{- define "kubevirt-stack.tolerations" -}}
{{- $result := list -}}
{{- if .global -}}
  {{- $result = .global -}}
{{- end -}}
{{- if .local -}}
  {{- $result = concat $result .local -}}
{{- end -}}
{{- if $result -}}
{{- toYaml $result -}}
{{- end -}}
{{- end }}
