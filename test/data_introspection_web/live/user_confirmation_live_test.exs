defmodule DataIntrospectionWeb.UserConfirmationLiveTest do
  @moduledoc false
  use DataIntrospectionWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  setup do
    %{user: insert(:user)}
  end

  describe "Confirm user" do
    test "renders confirmation page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/confirm/some-token")
      assert html =~ "Confirm Account"
    end
  end
end
