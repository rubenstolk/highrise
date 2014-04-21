module Highrise
  class Person < Subject
    include Pagination
    include Taggable
    include Searchable

    def tags
      self.attributes.has_key?("tags") ? self.attributes["tags"] : super
    end

    def company
      Company.find(company_id) if company_id
    end

    def name
      "#{first_name rescue ''} #{last_name rescue ''}".strip
    end

    def address
      contact_data.addresses.first
    end

    def web_address
      contact_data.web_addresses.first
    end

    def label
      'Party'
    end
    
    def field(field_label)
      custom_fields = attributes["subject_datas"] ||= []
      field = custom_fields.detect { |field|
        field.subject_field_label == field_label
      }
      field ? field.value : nil
    end
    
    def new_subject_data(field, value)
      Highrise::SubjectData.new(:subject_field_id => field.id, :subject_field_label => field.label, :value => value)
    end
    
    def set_field_value(field_label, new_value)
      custom_fields = attributes["subject_datas"] ||= []
      custom_fields.each { |field|
        return field.value = new_value if field.subject_field_label== field_label
      }
  
      SubjectField.find(:all).each { |custom_field| 
        if custom_field.label == field_label
          return attributes["subject_datas"] << new_subject_data(custom_field, new_value)
        end
      }
    end

    def transform_subject_field_label field_label
      field_label.downcase.tr(' ', '_')
    end
    
    def convert_method_to_field_label method
      custom_fields = attributes["subject_datas"] ||= []
      custom_fields.each { |field|
        method_name_from_field = transform_subject_field_label(field.subject_field_label)
        return field if method_name_from_field == method
      }
      nil
    end
    
    def method_missing(method_symbol, *args)
      method_name = method_symbol.to_s      
      field = convert_method_to_field_label(method_name)
      return field(field.subject_field_label) if field
      super
     end    
    
        
  end
end
