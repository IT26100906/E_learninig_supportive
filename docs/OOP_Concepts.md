# OOP concepts used (for the viva)

| Concept | Where | Explanation |
|---|---|---|
| **Encapsulation** | `User` (and all model classes) | Every field is `private`; data is read/changed only through getters/setters. Passwords are stored as hashes, never plain text. |
| **Abstraction** | `User` (abstract class), `UserRepository` (interface) | `User` declares abstract methods (`getRole`, `getType`, `canManageUsers`, `getHomePath`, `getMaxEnrollments`). `UserRepository` hides *how* data is stored, so `users.txt` could be replaced by a database without changing `UserService`. |
| **Inheritance** | `Student`, `PremiumStudent`, `Admin` extend `User` (`PremiumStudent` extends `Student`); every servlet extends `BaseServlet` | Common data/behaviour is written once in the parent. |
| **Polymorphism** | `getHomePath()`, `canManageUsers()`, `getMaxEnrollments()`, `getType()`, `getMembershipLabel()` | A `User` variable can hold a Student, PremiumStudent or Admin. The same call behaves differently, e.g. after login `redirect(user.getHomePath())` sends students to `/dashboard` and admins to `/admin/dashboard`; `AuthFilter` uses `user.canManageUsers()` to protect `/admin/*`. |
| **Enum with behaviour** | `StudentLevel` | Each constant (CHILD, SCHOOL, AL, UNDERGRAD) overrides `greeting()`, `subjects()`, `isValidDetail()`, `describe()` and `highlight()` - polymorphism without a class for every level. It also names the theme and dashboard page used for that level. |
| **Factory pattern** | `UserFactory` | Creates the correct subclass from the first column of `users.txt` (`STUDENT`, `PREMIUM`, `ADMIN`). |
| **Generics** | `Page<T>` | One pagination class for any list type. |
| **Exception handling** | `ValidationException`, `AuthException` | Business errors are reported with custom checked exceptions. |

# Database (JDBC)

* Users are stored in the SQL table `users` (H2 embedded database by default, MySQL optional - `db.properties`).
* `JdbcUserRepository` implements the same `UserRepository` interface as the old file version, so `UserService`, the servlets and the JSPs did not change (abstraction / loose coupling).
* Every query is a `PreparedStatement` with `?` parameters (no string concatenation), so SQL injection is not possible.
* `create / findAll / findById / findByEmail / update / delete` map to `INSERT / SELECT / UPDATE / DELETE`; each row becomes an object through `UserFactory.create`.
* `AppInitListener` creates the table at start-up and copies the old `data/users.txt` into it once (`FileUserRepository` is kept only for this import).
* Profile pictures are stored in `data/profile-pics/` (file name = student ID); the table keeps only the file name.
