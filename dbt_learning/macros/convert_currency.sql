{% macro convert_currency(amount_column, currency_column, target_currency='USD') %}

    case
        when upper({{ currency_column }}) = '{{ target_currency }}'
            then {{ amount_column }}

        {% if target_currency == 'USD' %}

        when upper({{ currency_column }}) = 'OMR'
            then {{ amount_column }} * 2.60

        when upper({{ currency_column }}) = 'EUR'
            then {{ amount_column }} * 1.08

        {% endif %}

        else {{ amount_column }}
    end

{% endmacro %}