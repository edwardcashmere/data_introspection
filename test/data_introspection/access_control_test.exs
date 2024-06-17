defmodule DataIntrospection.AccessControlTest do
  @moduledoc false
  use DataIntrospection.DataCase

  alias DataIntrospection.AccessControl
  alias DataIntrospection.AccessControl.Policy

  describe "create_policy/3" do
    test "with valid data creates a policy" do
      subject = insert(:user)
      resource = insert(:plot)
      action = "view"

      assert {:ok, %Policy{} = policy} = AccessControl.create_policy(subject, resource, action)
      assert policy.subject == "user.#{subject.id}"
      assert policy.resource == "plot.#{resource.id}"
      assert policy.action == "view"
    end

    test "with valid data upserts policy if it exists" do
      subject = insert(:user)
      resource = insert(:plot)
      action = "view"

      insert(:policy, subject: subject, resource: resource, action: action)
      assert {:ok, %Policy{} = policy} = AccessControl.create_policy(subject, resource, action)
      assert policy.subject == "user.#{subject.id}"
      assert policy.resource == "plot.#{resource.id}"
      assert policy.action == "view"
    end
  end

  describe "collect_subjects/1" do
    test "builds a list of subjects for user: user and global selector(*)" do
      user = insert(:user)

      subjects = AccessControl.collect_subjects(user)

      assert subjects == [user, "*"]

      # make sure it works with search_policies/1 function_exported?(
      assert [] == AccessControl.search_policies(subject: subjects)
    end
  end

  describe "collect_resources/1" do
    test "builds a list of resources for course: course and global selector(*)" do
      course = insert(:plot)

      resources = AccessControl.collect_resources(course)

      assert resources == [course, "plot.*", "*"]

      # make sure it works with search_policies/1 function_exported?(
      assert [] = AccessControl.search_policies(resources: resources)
    end
  end

  describe "collect_actions/1" do
    test "builds a list of actions:action itself resource type wildacard and global selector" do
      actions = AccessControl.collect_actions("view")

      assert actions == ["view", "*"]

      # make sure it works with search_policies/1 function_exported?(
      assert [] = AccessControl.search_policies(actions: actions)
    end
  end

  describe "search_policies/1" do
    test "search policies by specified subject(s), resource(s) or action(s) " do
      insert(:policy, subject: "user.1", resource: "plot.1", action: "view")

      insert(:policy, subject: "user.12", resource: "plot.1", action: "edit")

      assert length(AccessControl.search_policies()) == 2

      assert [subject: "user.1"]
             |> AccessControl.search_policies()
             |> length() == 1

      assert [subject: "user.12", action: "edit"]
             |> AccessControl.search_policies()
             |> length() == 1
    end
  end

  describe "check?/3" do
    setup do
      user = insert(:user)
      [plot_1, plot_2] = insert_list(2, :plot)
      insert(:policy, subject: user, resource: plot_1, action: "view")
      insert(:policy, subject: user, resource: plot_2, action: "*")
      [user: user, plot_1: plot_1, plot_2: plot_2]
    end

    test "should return true if a user the defined permission", %{
      user: user,
      plot_1: plot_1,
      plot_2: plot_2
    } do
      assert AccessControl.check?(user, plot_1, "view")
      assert AccessControl.check?(user, plot_2, "edit")
    end

    test "returns false is a user does not have the checked permissions ", %{
      user: user,
      plot_1: plot_1
    } do
      refute AccessControl.check?(user, plot_1, "edit")
    end
  end
end
