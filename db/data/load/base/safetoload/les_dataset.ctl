[MERGE INTO les_dataset
     USING(SELECT '@ds_name@' ds_name,
                 '@ds_desc@' ds_desc,
                 '@ds_dir@' ds_dir,
                 '@ds_seq@' ds_seq
            FROM dual) input
        ON (les_dataset.ds_name = input.ds_name)
 WHEN MATCHED THEN
     UPDATE SET ds_desc = input.ds_desc,
                ds_dir  = input.ds_dir,
                ds_seq  = input.ds_seq 
 WHEN NOT MATCHED THEN
     INSERT (ds_name,
             ds_desc,
             ds_dir,
             ds_seq)
     VALUES (input.ds_name,
             input.ds_desc,
             input.ds_dir,
             input.ds_seq)
]