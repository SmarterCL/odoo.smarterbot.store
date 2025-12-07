-- Private bucket for specs / documents
-- Execute in Supabase SQL editor
SELECT storage.create_bucket('specs', public := false);