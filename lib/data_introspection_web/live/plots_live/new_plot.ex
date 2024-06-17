defmodule DataIntrospectionWeb.PlotsLive.NewPlot do
  @moduledoc false
  use DataIntrospectionWeb, :live_view

  import DataIntrospectionWeb.PlotsLive.Helper
  import LiveSelect

  alias DataIntrospection.Plots
  alias DataIntrospection.Plots.Plot
  # alias NimbleCSV.RFC4180, as: CSV

  @allowable_operations ["+", "-", "*", "/"]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, dataset: [], plot_name: "", dataset_name: "", plot: %Plot{}, check_errors?: false)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("validate", %{"plot" => plot_params}, socket) do
    changeset = Plots.change_plot(socket.assigns.plot, plot_params)

    updated_changeset = maybe_push_event(socket, changeset, plot_params)

    form =
      updated_changeset
      |> Map.put(:action, :validate)
      |> to_form()


    # validate schema
    # maybe validate expression
    # maybe validate
    socket =
      socket
        |> assign(:form, form)
        |> assign(check_errors?: !updated_changeset.valid?)
      {:noreply, socket}
  end

  def handle_event("save", %{"plot" => plot_params}, socket) do
    {:noreply, save_plot(socket, socket.assigns.live_action, plot_params)}
  end

  def handle_event("live_select_change", %{"text" => text, "id" => live_select_id}, socket) do
    search_term = String.downcase(text)

    options =
      Enum.filter(socket.assigns.datasets, fn dataset ->
        dataset |> String.downcase() |> String.contains?(search_term)
      end)

    send_update(LiveSelect.Component, id: live_select_id, options: options)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:render_plot, data}, socket) do
    {:noreply, push_event(socket, "render-plot", %{dataset: data})}
  end

  defp maybe_push_event(_socket, changeset, plots_params) do
    case validate_expression(changeset, plots_params) do
      {changeset, data} ->
        if changeset.valid? do
          send(self(), {:render_plot, data})
        end

        changeset

      # push_event(socket, "render-plot", %{dataset: data})
      changeset ->
        changeset
    end
  end

  defp validate_expression(changeset, %{"expression" => ""}), do: changeset

  defp validate_expression(changeset, %{"dataset" => "", "expression" => _expression}) do
    Ecto.Changeset.add_error(changeset, :expression, "select a dataset first")
  end

  defp validate_expression(changeset, %{"dataset" => dataset, "expression" => expression}) do
    updated_expression = expression |> String.trim() |> String.downcase()

    if String.contains?(updated_expression, @allowable_operations) do
      case {String.contains?(updated_expression, "*"), String.contains?(updated_expression, "/"),
            String.contains?(updated_expression, "+"),
            String.contains?(updated_expression, "-")} do
        {true, _, _, _} ->
          parse_and_validate_csv_data(
            changeset,
            dataset,
            String.split(updated_expression, "*"),
            "*"
          )

        {_, true, _, _} ->
          parse_and_validate_csv_data(
            changeset,
            dataset,
            String.split(updated_expression, "/"),
            "/"
          )

        {_, _, true, _} ->
          parse_and_validate_csv_data(
            changeset,
            dataset,
            String.split(updated_expression, "+"),
            "+"
          )

        {_, _, _, true} ->
          parse_and_validate_csv_data(
            changeset,
            dataset,
            String.split(updated_expression, "-"),
            "-"
          )
      end
    else
      parse_and_validate_csv_data(changeset, dataset, updated_expression, nil)
    end
  end

  defp parse_and_validate_csv_data(
         changeset,
         dataset,
         [_first_expression, _second_expression] = expressions,
         operator
       )
       when is_list(expressions) do
    with {headers, first_row, data} <- [get_file_path(), dataset] |> Path.join() |> parse_csv(),
         true <- dataset_column_exists?(headers, expressions),
         {:ok, {first_value_index, second_value_index}} <-
           maybe_validate_column_type(headers, first_row, expressions) do
      {changeset,
       data
       |> Enum.map(fn row ->
         {Enum.at(row, first_value_index), Enum.at(row, second_value_index)}
       end)
       |> sanitize_data_and_perform_operation(operator)}
    else
      {:error, error} ->
        Ecto.Changeset.add_error(changeset, :expression, error)

      false ->
        Ecto.Changeset.add_error(
          changeset,
          :expression,
          "one of the columns does not exist in the dataset"
        )
    end
  end

  defp parse_and_validate_csv_data(
         changeset,
         _dataset,
         expressions,
         _operator
       )
       when is_list(expressions) do
    Ecto.Changeset.add_error(
      changeset,
      :expression,
      "multiple operations detected, only one operation is allowed"
    )
  end

  defp parse_and_validate_csv_data(changeset, dataset, expression, _) do
    with {headers, first_row, data} <- [get_file_path(), dataset] |> Path.join() |> parse_csv(),
         true <- dataset_column_exists?(headers, expression),
         {:ok, value_index} <- maybe_validate_column_type(headers, first_row, expression) do
      {changeset, Enum.map(data, fn row -> Enum.at(row, value_index) end)}
    else
      {:error, error} ->
        Ecto.Changeset.add_error(changeset, :expression, error)

      false ->
        Ecto.Changeset.add_error(changeset, :expression, "column does not exist in the dataset")
    end
  end

  defp maybe_validate_column_type(
         headers,
         first_row,
         [first_expression, second_expression] = expressions
       )
       when is_list(expressions) do
    updated_headers =
      Enum.map(headers, fn value_string -> value_string |> String.trim() |> String.downcase() end)


    first_expression_index =
      Enum.find_index(updated_headers, fn string_term -> string_term == String.trim(first_expression) end)

    second_expression_index =
      Enum.find_index(updated_headers, fn string_term -> string_term == String.trim(second_expression) end)

    first_row_value = Enum.at(first_row, first_expression_index)
    second_row_value = Enum.at(first_row, second_expression_index)

    case {validate_expression(first_row_value), validate_expression(second_row_value)} do
      {{:error, _}, {:error, _}} ->
        {:error, "Invalid expression on both sides of operator, must be of type float or integer"}

      {{:error, _}, _} ->
        {:error, "Invalid expression on left side of operator, must be of type float or integer"}

      {_, {:error, _}} ->
        {:error, "Invalid expression on right side of operator, must be of type float or integer"}

      _ ->
        {:ok, {first_expression_index, second_expression_index}}
    end
  end

  defp maybe_validate_column_type(headers, _first_row, expression) do
    index =
      headers
      |> Enum.map(fn value_string -> value_string |> String.trim() |> String.downcase() end)
      |> Enum.find_index(fn string_term -> string_term == expression end)

    {:ok, index}
  end

  defp dataset_column_exists?(headers, [_first_expression, _second_expression] = expressions)
       when is_list(expressions) do
    updated_headers =
      headers |> Enum.map(fn string_term -> string_term |> String.trim() |> String.downcase() end)

    expressions |> Enum.map(fn string_term -> string_term |> String.trim() |> String.downcase() end) |> Enum.all?(&(&1 in updated_headers))
  end

  defp dataset_column_exists?(headers, expression) do
    headers |> Enum.map(&String.downcase/1) |> Enum.member?(expression)
  end

  defp save_plot(socket, :new, plot_params) do
    case Plots.create_plot(plot_params) do
      {:ok, _plot} ->
        socket
        |> put_flash(:info, "Plot created successfully.")
        |> push_navigate(to: ~p"/plots/private/#{socket.assigns.current_user}")

      {:error, changeset} ->
        socket
        |> assign(form: to_form(changeset))
        |> put_flash(:error, "Error creating plot.")
    end
  end

  defp save_plot(socket, :edit, plot_params) do
    case Plots.update_plot(socket.assigns.plot, plot_params) do
      {:ok, _plot} ->
        socket
        |> put_flash(:info, "Plot updated successfully.")
        |> push_navigate(to: ~p"/plots/private/#{socket.assigns.current_user}")

      {:error, changeset} ->
        socket
        |> assign(form: to_form(changeset))
        |> put_flash(:error, "Error updating plot.")
    end
  end

  defp validate_expression(expression) do
    case String.contains?(expression, ".") do
      true -> convert_expression_to_float(expression)
      false -> convert_expression_to_integer(expression)
    end
  end

  defp convert_expression_to_float(expression) do
    String.to_float(expression)
  rescue
    _ -> {:error, "Invalid expression, must be of type float or integer"}
  end

  defp convert_expression_to_integer(expression) do
    String.to_integer(expression)
  rescue
    _ -> {:error, "Invalid expression, must be of type float or integer"}
  end

  defp apply_action(socket, :new, _params) do
    form = %Plot{} |> Plots.change_plot(%{title: "New Plot"}) |> to_form()
    datasets = list_data_sets()
    assign(socket, form: form, datasets: datasets)
  end

  defp apply_action(socket, :edit, params) do
    plot = Plots.get_plot!(params["id"])
    form = plot |> Plots.change_plot(%{}) |> to_form()
    datasets = list_data_sets()
    # find the plot by id
    # create a form and allow edit
    assign(socket, form: form, datasets: datasets, plot: plot)
  end

  defp apply_action(socket, _, _params), do: socket

  defp list_data_sets do
    File.ls!("/Users/dev/personal/data_introspection/priv/static/files")
  end
end
