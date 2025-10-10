import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi3";
using Http;
using Rest;

// @service({ title: "Manchester API" })
@server("http://localhost:8000", "Local Rails API")
namespace Manchester;

model User {
  id: string;
  name: string;
  email: string;
  age?: int32;
}

@route("/api/users")
interface Users {
  list(): User[];
  create(@body user: User): User;
  read(@path id: string): User;
  update(@path id: string, @body user: User): User;
  delete(@path id: string): void;
}