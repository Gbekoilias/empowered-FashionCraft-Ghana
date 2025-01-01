import plotly
import json
import options
import strformat
import sequtils
import tables

type
  ChartType* = enum
    Bar, Line, Pie, Scatter

  ChartData* = object
    labels*: seq[string]
    values*: seq[float]
    title*: string
    subtitle*: Option[string]

proc createChart*(data: ChartData, chartType: ChartType): Plot =
  var p = createPlot()
  p.layout.title = data.title
  if data.subtitle.isSome:
    p.layout.showlegend = true
    p.layout.legend = newLayout()
    p.layout.legend.title = data.subtitle.get()

  case chartType:
  of Bar:
    var trace = Trace[float](mode: PlotMode.Lines, `type`: PlotType.Bar)
    trace.ys = data.values
    trace.xs = data.labels
    p.add(trace)
  
  of Line:
    var trace = Trace[float](mode: PlotMode.LinesMarkers, `type`: PlotType.Scatter)
    trace.ys = data.values
    trace.xs = data.labels
    p.add(trace)
  
  of Pie:
    var trace = Trace[float](`type`: PlotType.Pie)
    trace.values = data.values
    trace.labels = data.labels
    p.add(trace)
  
  of Scatter:
    var trace = Trace[float](mode: PlotMode.Markers, `type`: PlotType.Scatter)
    trace.ys = data.values
    trace.xs = data.labels
    p.add(trace)

  p.layout.width = 800
  p.layout.height = 600
  p.layout.margin = Margin(l: 50, r: 50, b: 50, t: 50)
  return p

proc saveChart*(plot: Plot, filename: string) =
  saveImage(plot, filename)

proc createYouthImpactDashboard*(data: TableRef[string, seq[float]], 
                                metrics: seq[string]): Plot =
  var p = createPlot()
  p.layout.title = "Youth Empowerment Impact Metrics"
  p.layout.showlegend = true

  for metric in metrics:
    var trace = Trace[float](mode: PlotMode.LinesMarkers, 
                            `type`: PlotType.Scatter,
                            name: metric)
    trace.ys = data[metric]
    trace.xs = toSeq(1..data[metric].len)
    p.add(trace)

  p.layout.width = 1000
  p.layout.height = 600
  return p

proc exportChartData*(data: ChartData, filename: string) =
  let jsonData = %*{
    "labels": data.labels,
    "values": data.values,
    "title": data.title,
    "subtitle": if data.subtitle.isSome: data.subtitle.get() else: ""
  }
  writeFile(filename, $jsonData)
  let data = ChartData(
  labels: @["Program A", "Program B", "Program C"],
  values: @[75.0, 82.0, 90.0],
  title: "Youth Program Impact",
  subtitle: some("Participation Rates")
)
let chart = createChart(data, ChartType.Bar)
saveChart(chart, "impact.png")