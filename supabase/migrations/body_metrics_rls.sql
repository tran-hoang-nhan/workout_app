-- Enable RLS on body_metrics table
ALTER TABLE body_metrics ENABLE ROW LEVEL SECURITY;

-- Policy for users to INSERT their own weight records
CREATE POLICY "Users can insert their own weight records"
ON body_metrics FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Policy for users to SELECT their own weight records
CREATE POLICY "Users can view their own weight records"
ON body_metrics FOR SELECT
USING (auth.uid() = user_id);

-- Policy for users to UPDATE their own weight records
CREATE POLICY "Users can update their own weight records"
ON body_metrics FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy for users to DELETE their own weight records
CREATE POLICY "Users can delete their own weight records"
ON body_metrics FOR DELETE
USING (auth.uid() = user_id);
