defmodule UaiShotWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use UaiShotWeb, :controller
      use UaiShotWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.

  定义web界面的入口点，例如
  比如控制器，视图，通道等等。
  这可以在您的应用程序中使用作为:
    使用UaiShotWeb:控制器
    使用UaiShotWeb:视图
  下面的定义将对每个视图执行，
  所以要保持它们简短、干净、聚焦
  关于导入、使用和别名。
  不要在引用的表达式中定义函数
  在下面。相反，在模块中定义任何辅助函数
  然后导入这些模块。

  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: UaiShotWeb
      import Plug.Conn
      alias UaiShotWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/uai_shot_web/templates",
        namespace: UaiShotWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      alias UaiShotWeb.Router.Helpers, as: Routes
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
