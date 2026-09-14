-- Keep the product evidence bucket private and usable by authenticated clients.
-- The bucket itself is created by the previous product_submission_storage_and_api_access migration.

grant select on table storage.buckets to authenticated;
grant select, insert, update, delete on table storage.objects to authenticated;

update storage.buckets
set public = false,
    file_size_limit = 10485760,
    allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp']
where id = 'product-labels';
