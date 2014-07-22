defmodule HTTParrot.ImageHandler do
  @moduledoc """
  Returns an image.
  """
  use HTTParrot.Cowboy, methods: ~w(GET HEAD OPTIONS)

  def content_types_provided(req, state) do
    {[{{"image", "png", []}, :get_png},
      {{"image", "jpeg", []}, :get_jpeg}], req, state}
  end

  @png Base.decode64!("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==")
  @jpeg Base.decode64!("/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAAMCAgICAgMCAgIDAwMDBAYEBAQEBAgGBgUGCQgKCgkICQkKDA8MCgsOCwkJDRENDg8QEBEQCgwSExIQEw8QEBD/yQALCAABAAEBAREA/8wABgAQEAX/2gAIAQEAAD8A0s8g/9k=")

  def get_png(req, state), do: {@png, req, state}
  def get_jpeg(req, state), do: {@jpeg, req, state}
end
