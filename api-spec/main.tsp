import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi3";
using Http;
using Rest;

@service(#{ title: "Manchester API" })
@server("http://localhost:8000", "Local Rails API")
namespace Manchester;

// モデル定義
model User {
  id: string;
  name: string;
  email: string;
  age?: int32;
}

// APIルート
@route("/api/users")
interface Users {
  @get list(): User[];
  @post create(@body user: User): User;
  @get read(@path id: string): User;
  @put update(@path id: string, @body user: User): User;
  @delete remove(@path id: string): void;
}