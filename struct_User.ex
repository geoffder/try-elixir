defmodule User do
  # fields without defaults are implicitly nil
  # empty fields must go first in the definition as :email is below.
  # @enforce_keys :name  would require assigning a value to name name field
  # whenever a new User is created.
  defstruct [:email, name: "Geoff", age: 30]
end
