import Plotly from "plotly.js-dist-min";

export const plotJS = {
  mounted() {
    const container = document.getElementById("plotly-container");

    this.handleEvent("render-plot", function ({ dataset: payload }) {
      console.log(payload, "payload shhdfjjfsms");
      context_div = document.createElement("div");
      context_div.setAttribute("id", "new-plot");

      let trace = {
        x: payload,
        type: "histogram",
      };
      let data = [trace];

      Plotly.newPlot(context_div, data);
      container.appendChild(context_div);
    });

    this.handleEvent("render-plots", function ({ datasets: payload }) {
      payload.forEach((data, _index) => {
        console.log(payload, "payload");
        context_div = document.getElementById(data.id);
        context_div.setAttribute("data-role", "plots");

        let trace = {
          x: data.dataset,
          type: "histogram",
        };
        let traceData = [trace];

        Plotly.newPlot(context_div, traceData);
      });
    });
  },
};
