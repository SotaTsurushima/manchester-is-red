import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi3";
using Http;
using Rest;

@service(#{ title: "Manchester United API" })
@server("http://localhost:8000", "Rails API")
namespace Manchester;

// エラーレスポンスモデル
model SimpleErrorResponse {
  success: false;
  error: string;
}

model DetailedErrorResponse {
  success: false;
  error: string;
  class: string;
  full_message: string;
}

model AuthErrorResponse {
  error: string;
}

// 成功レスポンスモデル
model SuccessResponse<T> {
  success: true;
  data: T;
}

model MessageSuccessResponse {
  success: true;
  message: string;
}

// Userモデル
model User {
  id: integer;
  name: string;
  nickname?: string;
  image?: string;
  email: string;
  role: "admin" | "user";
  provider: string;
  uid: string;
}

// Playerモデル（データベーススキーマに基づく）
model Player {
  id: integer;
  name: string;
  number: integer;
  position?: string;
  image?: string;
  goals?: integer;
  assists?: integer;
  yellow_card?: integer;
  red_card?: integer;
  appearances?: integer;
  market_value?: decimal;
  salary?: integer;
  created_at: string;
  updated_at: string;
}

// Player作成・更新用のリクエストモデル
model PlayerCreateRequest {
  name: string;
  number: integer;
  position?: string;
  salary?: integer;
  market_value?: decimal;
  // file: multipart/form-data でアップロード
}

model PlayerUpdateRequest {
  name?: string;
  number?: integer;
  position?: string;
  salary?: integer;
  market_value?: decimal;
  // file: multipart/form-data でアップロード（オプション）
}

// Player詳細レスポンス（show用）
model PlayerDetail {
  id: integer;
  name: string;
  number: integer;
  position?: string;
  image?: string;
}

// Player作成レスポンス（create用）
model PlayerCreateResponse {
  id: integer;
  name: string;
  number: integer;
  position?: string;
  image?: string;
  url: string;  // アップロードされた画像のURL
}

// Player削除レスポンス
model PlayerDeleteResponse {
  id: integer;
}

// Teamモデル
model Team {
  id: integer;
  name: string;
  crest_url?: string;
  created_at: string;
  updated_at: string;
}

// Matchモデル
model Match {
  id: integer;
  home_team_id: integer;
  away_team_id: integer;
  utc_date: string;  // ISO 8601 datetime
  competition: string;
  score?: string;
  venue?: string;
  status?: string;
  referees?: string;
  created_at: string;
  updated_at: string;
}

// Match詳細レスポンス（show用）
model MatchDetail {
  id: integer;
  home_team: Team;
  away_team: Team;
  utc_date: string;
  competition: string;
  score?: string;
  venue?: string;
  status?: string;
  referees?: string;
}

// Match一覧レスポンス（index用）
model MatchListResponse {
  matches: MatchDetail[];
  competition: string;
  page: integer;
  per_page: integer;
  total: integer;
  total_pages: integer;
  next_page?: integer;
  prev_page?: integer;
}

// Transfer Newsモデル
model TransferNews {
  title: string;
  url: string;
  date: string;  // ISO 8601 datetime
  description?: string;
  image?: string;
  source: string;
  reliability: string;
}

// Transfer Newsレスポンス（修正版）
model TransferNewsSource {
  success: boolean;
  data: TransferNews[];
}

model TransferNewsResponse {
  sky_sports: TransferNewsSource;
  guardian: TransferNewsSource;
  ornstein: TransferNewsSource;
}

// Injury Playerモデル
model InjuryPlayer {
  number?: string;
  injury: string;
  return_date?: string;
}

// APIルート
@tag("Users")
@route("/users")
interface Users {
  @get list(): SuccessResponse<User[]> | SimpleErrorResponse | DetailedErrorResponse;
  @get read(@path id: integer): SuccessResponse<User> | SimpleErrorResponse | DetailedErrorResponse;
}

@tag("Players")
@route("/players")
interface Players {
  @get list(): SuccessResponse<Player[]> | SimpleErrorResponse | DetailedErrorResponse;
  @post create(@body request: PlayerCreateRequest): SuccessResponse<PlayerCreateResponse> | SimpleErrorResponse | DetailedErrorResponse;
  @get read(@path id: integer): SuccessResponse<PlayerDetail> | SimpleErrorResponse | DetailedErrorResponse;
  @put update(@path id: integer, @body request: PlayerUpdateRequest): SuccessResponse<PlayerDetail> | SimpleErrorResponse | DetailedErrorResponse;
  @delete remove(@path id: integer): SuccessResponse<PlayerDeleteResponse> | SimpleErrorResponse | DetailedErrorResponse;
}

@tag("Matches")
@route("/matches")
interface Matches {
  @get list(
    @query competition_id?: string,
    @query page?: integer,
    @query per_page?: integer
  ): { matches: MatchListResponse } | SimpleErrorResponse | DetailedErrorResponse;
  @get read(@path id: integer): { match: MatchDetail } | SimpleErrorResponse | DetailedErrorResponse;
}

@tag("Transfers")
@route("/transfers")
interface Transfers {
  @get list(): SuccessResponse<TransferNewsResponse> | SimpleErrorResponse | DetailedErrorResponse;
}

@tag("Injuries")
@route("/injuries")
interface Injuries {
  @get list(): SuccessResponse<InjuryPlayer[]> | SimpleErrorResponse | DetailedErrorResponse;
}

@tag("Admin")
interface Admin {
  @route("/admin/batch/matches")
  @post batchMatches(): MessageSuccessResponse | AuthErrorResponse | SimpleErrorResponse | DetailedErrorResponse;

  @route("/admin/batch/players_stats")
  @post batchPlayersStats(): MessageSuccessResponse | AuthErrorResponse | SimpleErrorResponse | DetailedErrorResponse;

  @route("/admin/batch/teams")
  @post batchTeams(): MessageSuccessResponse | AuthErrorResponse | SimpleErrorResponse | DetailedErrorResponse;
}