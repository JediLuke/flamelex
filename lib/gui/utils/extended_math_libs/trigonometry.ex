# defmodule Flamelex.GUI.GeometryLib.Trigonometry do
#   use Flamelex.ProjectAliases


#     #NOTE: How Scenic draws triangles
#     #      --------------------------
#     #      Scenic uses 3 points to draw a triangle, which look like this:
#     #
#     #           x - point1
#     #           |\
#     #           | \ x - point2 (apex of triangle)
#     #           | /
#     #           |/
#     #           x - point


#   def equilateral_triangle_coords(%Coordinates{} = centroid, centroid_to_vertex_length, _rotation \\ 0) do
#     cvl = centroid_to_vertex_length # for convenience

#     {
#       {centroid.x - :math.sqrt(3) * cvl / 2, centroid.y + cvl/2},
#       {centroid.x, centroid.y - cvl},
#       {centroid.x + :math.sqrt(3) * cvl / 2, centroid.y + cvl/2}
#     }
#   end
# end
