module Database.PostgreSQL.Migration.Database where

import Control.Monad.Logger (LoggingT)
import Control.Monad.Reader (liftIO)
import Data.Pool (Pool, withResource)
import Data.String
import Data.Time
import Database.PostgreSQL.Simple

import Database.PostgreSQL.Migration.Entity
import Database.PostgreSQL.Migration.Util

instance ToRow MigrationRecord

instance FromRow MigrationRecord

toMigrationRecord :: MigrationMeta -> MigrationState -> UTCTime -> MigrationRecord
toMigrationRecord migrationMeta state createdAt =
  MigrationRecord
    { mrNumber = mmNumber migrationMeta
    , mrName = mmName migrationMeta
    , mrDescription = mmDescription migrationMeta
    , mrState = state
    , mrCreatedAt = createdAt
    }

getMigrationsFromDb :: Pool Connection -> String -> LoggingT IO [MigrationRecord]
getMigrationsFromDb dbPool dbPrefix = do
  let action conn = query_ conn (fromString $ f' "SELECT * FROM %s ORDER BY number ASC;" [createEntityName dbPrefix])
  runDB dbPool action

ensureMigrationTable :: Pool Connection -> String -> LoggingT IO ()
ensureMigrationTable dbPool dbPrefix = do
  let sql =
        fromString $
          f'
            "create table if not exists %s \
            \ ( \
            \     number integer                  not null \
            \         constraint %s_pk \
            \             primary key, \
            \     name            varchar                  not null, \
            \     description     varchar                  not null, \
            \     state           varchar                  not null, \
            \     created_at      timestamp with time zone not null \
            \ ); \
            \ create unique index if not exists %s_number_uindex \
            \    on %s (number); "
            [ createEntityName dbPrefix
            , createEntityName dbPrefix
            , createEntityName dbPrefix
            , createEntityName dbPrefix
            ]
  let action conn = execute_ conn sql
  runDB dbPool action
  return ()

startMigration :: Pool Connection -> String -> MigrationMeta -> LoggingT IO ()
startMigration dbPool dbPrefix meta = do
  now <- liftIO getCurrentTime
  let entity = toMigrationRecord meta _STARTED now
  let action conn = execute conn (fromString $ f' "INSERT INTO %s VALUES (?,?,?,?,?);" [createEntityName dbPrefix]) entity
  runDB dbPool action
  return ()

endMigration :: Pool Connection -> String -> MigrationMeta -> LoggingT IO ()
endMigration dbPool dbPrefix meta = do
  let action conn = execute conn (fromString $ f' "UPDATE %s SET state = 'DONE' WHERE number = ?;" [createEntityName dbPrefix]) [mmNumber meta]
  runDB dbPool action
  return ()

startTransaction :: Pool Connection -> LoggingT IO ()
startTransaction dbPool = do
  let action conn = execute_ conn "BEGIN TRANSACTION;"
  runDB dbPool action
  return ()

commitTransaction :: Pool Connection -> LoggingT IO ()
commitTransaction dbPool = do
  let action conn = execute_ conn "COMMIT;"
  runDB dbPool action
  return ()

rollbackTransaction :: Pool Connection -> LoggingT IO ()
rollbackTransaction dbPool = do
  let action conn = execute_ conn "ROLLBACK;"
  runDB dbPool action
  return ()

runDB dbPool action = liftIO $ withResource dbPool action

createEntityName dbPrefix = f' "%smigration" [dbPrefix]
