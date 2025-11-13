defmodule Producto do
  defstruct [:nombre, :stock, :precio_sin_iva, :iva]
end

defmodule Precios do
  # Calcula el precio final de un producto
  def precio_final(%Producto{nombre: n, precio_sin_iva: ps, iva: iva}) do
    # simulamos trabajo “pesado”
    :timer.sleep(10)
    precio = ps * (1 + iva)
    IO.puts("#{n} → #{precio} COP")
    {n, precio}
  end

  # Procesamiento secuencial
  def precios_secuencial(productos) do
    Enum.map(productos, &precio_final/1)
  end

  # Procesamiento concurrente
  def precios_concurrente(productos) do
    productos
    |> Enum.map(fn p -> Task.async(fn -> precio_final(p) end) end)
    |> Task.await_many()
  end

  # Genera lista de ejemplo
  def lista_productos do
    [
      %Producto{nombre: "Arroz", stock: 30, precio_sin_iva: 2000, iva: 0.19},
      %Producto{nombre: "Leche", stock: 20, precio_sin_iva: 3000, iva: 0.05},
      %Producto{nombre: "Pan", stock: 50, precio_sin_iva: 1000, iva: 0.10},
      %Producto{nombre: "Huevos", stock: 40, precio_sin_iva: 500, iva: 0.19}
    ]
  end

  def iniciar do
    productos = lista_productos()

    # Versión secuencial
    IO.puts("\n=== PROCESO SECUENCIAL ===")
    {t1, lista1} = :timer.tc(fn -> precios_secuencial(productos) end)

    IO.puts("\n=== PROCESO CONCURRENTE ===")
    {t2, lista2} = :timer.tc(fn -> precios_concurrente(productos) end)

    IO.puts("\nResultados SECUNCIAL:")
    Enum.each(lista1, fn {n, p} -> IO.puts("  #{n}: #{p} COP") end)
    IO.puts("\nResultados CONCURRENTE:")
    Enum.each(lista2, fn {n, p} -> IO.puts("  #{n}: #{p} COP") end)

    speedup = Float.round(t1 / t2, 2)
    IO.puts("\nSpeedup (secuencial / concurrente) = #{speedup}x")
  end
end

Precios.iniciar()
