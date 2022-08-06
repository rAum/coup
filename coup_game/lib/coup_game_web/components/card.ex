defmodule CoupGameWeb.Components.Card do
  use Phoenix.Component

  def card(assigns) do
    ~H"""
    <div class="h-full w-1/2 min-h-max m-1 p-1">
      <figure class="flex flex-col rounded-xl shadow-xl m-1 min-h-full bg-slate-700">
      <div class="flex w-64 h-64 overflow-hidden bg-gray-800">
        <img class="rounded-xl m-1" src={"/images/" <> @card <> ".png"}>
      </div>
      <div class="basis-2/3">
        <figcaption class="font-medium p-2">
          <div class="text-sky-500 dark:text-sky-400 text-center">
            <%= @card_name %>
          </div>
          <div class="text-left space-y-4">
          <blockquote>
            <p class="text-lg font-medium">
            <%= @card_desc %>
            </p>
          </blockquote>
        </div>
        </figcaption>
      </div>
      </figure>
    </div>
    """
  end
end
