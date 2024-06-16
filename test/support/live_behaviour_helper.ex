defmodule DataIntrospectionWeb.LiveBehaviourHelpers do
  @moduledoc false
  import Phoenix.LiveViewTest

  @spec click_element(any(), String.t()) :: any()
  def click_element(lv, element_selector) do
    lv
    |> element(element_selector)
    |> render_click()

    lv
  end

  @doc """
  Helper function to ensure we don't have any issues with string and HTML
  string comparisons that have historically plauged us.
  """
  @spec html_contains_string?(Phoenix.HTML.unsafe(), String.t()) :: boolean()
  def html_contains_string?(html, string) do
    html =~
      string
      |> Phoenix.HTML.html_escape()
      |> Phoenix.HTML.safe_to_string()
  end
end
