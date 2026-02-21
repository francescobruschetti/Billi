-- elimina tutte le tabelle
-- elimina funzioni
-- elimina policies
-- elimina indici

-- Ma:
-- NON elimina utenti auth
-- NON elimina storage
-- NON elimina estension
drop schema public cascade;
create schema public;
