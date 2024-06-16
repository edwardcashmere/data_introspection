import Plotly from "plotly.js-dist-min";

export const plottJS = {
  mounted() {
    const container = document.getElementById("plotly-container");

    let x = [];
    for (var i = 0; i < 500; i++) {
      x[i] = Math.random();
    }

    let y = [];
    for (var i = 0; i < 500; i++) {
      y[i] = Math.random();
    }

    let trace = {
      x: x,
      type: "histogram",
    };

    let trace_y = {
      x: y,
      type: "histogram",
    };

    let data_x = [trace];
    let data_y = [trace_y];

    x_context = document.createElement("div");
    y_context = document.createElement("div");

    x_plot = Plotly.newPlot(x_context, data_x);
    y_plot = Plotly.newPlot(y_context, data_y);

    container.appendChild(x_context);
    container.appendChild(y_context);

    console.log("Plotly.js mounted");
  },
};
