import * as d3 from 'd3';

class DataVisualizer {
  constructor(containerId) {
    this.container = d3.select(`#${containerId}`);
    this.margin = { top: 40, right: 30, bottom: 50, left: 60 };
    this.width = 800 - this.margin.left - this.margin.right;
    this.height = 500 - this.margin.top - this.margin.bottom;
  }

  createLineChart(data, options = {}) {
    const svg = this.initializeSVG();
    const { xScale, yScale } = this.createScales(data, options);
    
    this.addAxes(svg, xScale, yScale, options);
    this.drawLine(svg, data, xScale, yScale);
    this.addTooltip(svg, data, xScale, yScale);
    
    if (options.title) this.addTitle(svg, options.title);
  }

  createBarChart(data, options = {}) {
    const svg = this.initializeSVG();
    const { xScale, yScale } = this.createScales(data, options, true);
    
    this.addAxes(svg, xScale, yScale, options);
    this.drawBars(svg, data, xScale, yScale);
    this.addTooltip(svg, data, xScale, yScale);
    
    if (options.title) this.addTitle(svg, options.title);
  }

  initializeSVG() {
    return this.container.append('svg')
      .attr('width', this.width + this.margin.left + this.margin.right)
      .attr('height', this.height + this.margin.top + this.margin.bottom)
      .append('g')
      .attr('transform', `translate(${this.margin.left},${this.margin.top})`);
  }

  createScales(data, options, isBar = false) {
    const xScale = isBar 
      ? d3.scaleBand().range([0, this.width]).padding(0.1)
      : d3.scaleLinear().range([0, this.width]);

    const yScale = d3.scaleLinear()
      .range([this.height, 0]);

    xScale.domain(isBar ? data.map(d => d.label) : d3.extent(data, d => d.x));
    yScale.domain([0, d3.max(data, d => d.y) * 1.1]);

    return { xScale, yScale };
  }

  addAxes(svg, xScale, yScale, options) {
    svg.append('g')
      .attr('transform', `translate(0,${this.height})`)
      .call(d3.axisBottom(xScale))
      .selectAll('text')
      .attr('transform', 'rotate(-45)')
      .style('text-anchor', 'end');

    svg.append('g')
      .call(d3.axisLeft(yScale));

    if (options.xLabel) {
      svg.append('text')
        .attr('x', this.width / 2)
        .attr('y', this.height + 40)
        .style('text-anchor', 'middle')
        .text(options.xLabel);
    }

    if (options.yLabel) {
      svg.append('text')
        .attr('transform', 'rotate(-90)')
        .attr('y', -40)
        .attr('x', -this.height / 2)
        .style('text-anchor', 'middle')
        .text(options.yLabel);
    }
  }

  drawLine(svg, data, xScale, yScale) {
    const line = d3.line()
      .x(d => xScale(d.x))
      .y(d => yScale(d.y));

    svg.append('path')
      .datum(data)
      .attr('class', 'line')
      .attr('fill', 'none')
      .attr('stroke', 'steelblue')
      .attr('stroke-width', 2)
      .attr('d', line);
  }

  drawBars(svg, data, xScale, yScale) {
    svg.selectAll('rect')
      .data(data)
      .enter()
      .append('rect')
      .attr('x', d => xScale(d.label))
      .attr('y', d => yScale(d.y))
      .attr('width', xScale.bandwidth())
      .attr('height', d => this.height - yScale(d.y))
      .attr('fill', 'steelblue');
  }

  addTooltip(svg, data, xScale, yScale) {
    const tooltip = d3.select('body').append('div')
      .attr('class', 'tooltip')
      .style('opacity', 0)
      .style('position', 'absolute')
      .style('background-color', 'white')
      .style('border', '1px solid black')
      .style('padding', '5px');

    svg.selectAll('.hover-area')
      .data(data)
      .enter()
      .append('rect')
      .attr('class', 'hover-area')
      .attr('x', d => xScale(d.x) - 5)
      .attr('y', 0)
      .attr('width', 10)
      .attr('height', this.height)
      .attr('fill', 'transparent')
      .on('mouseover', (event, d) => {
        tooltip.transition()
          .duration(200)
          .style('opacity', .9);
        tooltip.html(`Value: ${d.y}`)
          .style('left', (event.pageX + 10) + 'px')
          .style('top', (event.pageY - 28) + 'px');
      })
      .on('mouseout', () => {
        tooltip.transition()
          .duration(500)
          .style('opacity', 0);
      });
  }

  addTitle(svg, title) {
    svg.append('text')
      .attr('x', this.width / 2)
      .attr('y', -10)
      .style('text-anchor', 'middle')
      .style('font-size', '16px')
      .text(title);
  }
}

export default DataVisualizer;
const visualizer = new DataVisualizer('chart-container');
visualizer.createLineChart(data, { 
  title: 'Impact Trends',
  xLabel: 'Time Period',
  yLabel: 'Impact Score'
});