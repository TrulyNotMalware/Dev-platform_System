echo "======================================="
echo "Create nfs serviceAccount & Provisioner"
echo "======================================="

template_location="yamls/templates/"
nfs_template="nfs-template.yaml"
storage_template="storage-class-template.yaml"
name_space="dev-project"
storage_class_name="nfs-storageclass"

#Copy & replace namespace.
cp ${template_location}${nfs_template} yamls/created/nfs-sa.yaml
sed -i "s/NAME_SPACE$/${name_space}/g" yamls/created/nfs-sa.yaml

#Apply
#kubectl apply -f yamls/created/nfs-sa.yaml

#Create Storage class for dynamic provisioning.
cp ${template_location}${storage_template} yamls/created/storage-class.yaml
sed -i "s/CLASS_NAME$/${storage_class_name}/g" yamls/created/storage-class.yaml

#Apply
#kubectl apply -f yamls/create/storage-class.yaml

