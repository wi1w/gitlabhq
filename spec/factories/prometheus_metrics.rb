FactoryBot.define do
  factory :prometheus_metric, class: PrometheusMetric do
    title 'title'
    query 'avg(metric)'
    y_label 'y_label'
    unit 'm/s'
    group :business
    legend 'legend'
    project
  end
end
